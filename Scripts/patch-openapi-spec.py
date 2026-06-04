#!/usr/bin/env python3
"""
Patches the CardSight OpenAPI spec for compatibility with Apple's
swift-openapi-generator.

The CardSight API is an OpenAPI 3.1 document that uses two constructs the Swift
generator does not fully support. Both are rewritten in place so that the
generated client is correct and forward-compatible:

1. Nullable schemas expressed as ``anyOf: [<schema>, {"type": "null"}]``
   swift-openapi-generator cannot represent the ``{"type": "null"}`` branch, so
   it emits a warning ("Schema 'null' is not supported") and SILENTLY DROPS the
   entire property. Fields such as ``PricingRecord.url``, ``MarketplaceRecord.price``,
   or ``ReleaseCalendarEntry.release_date`` therefore never appear on the
   generated Swift types -- and because the parent objects also declare
   ``additionalProperties: false`` (see below), decoding a real API response that
   contains those fields fails outright.

   This script collapses each nullable union into its single non-null schema
   (preserving sibling keywords like ``description``) and removes the property
   from its parent ``required`` list. The generator then renders it as a normal
   Swift optional, which decodes a JSON ``null`` (or an absent key) correctly.

2. ``additionalProperties: false``
   The generator enforces this strictly via ``ensureNoAdditionalProperties``, so
   any field the API adds in the future -- or any field we failed to model --
   causes a hard decode failure. Removing the constraint makes decoding
   forward-compatible: unknown fields are ignored. This follows the
   swift-openapi-generator maintainers' official recommendation for
   forward-compatibility:
   https://github.com/apple/swift-openapi-generator/issues/608

Both transforms walk the entire document, so new endpoints and schemas are
handled automatically with no hand-maintained allow-list.
"""
import json
import sys


def _is_null_branch(schema) -> bool:
    """True if `schema` is the ``{"type": "null"}`` arm of a nullable union."""
    return isinstance(schema, dict) and schema.get("type") == "null"


def _schema_is_nullable(schema) -> bool:
    """True if `schema` models a value that may be JSON ``null``."""
    if not isinstance(schema, dict):
        return False
    for keyword in ("anyOf", "oneOf"):
        branches = schema.get(keyword)
        if isinstance(branches, list) and any(_is_null_branch(b) for b in branches):
            return True
    type_value = schema.get("type")
    if isinstance(type_value, list) and "null" in type_value:
        return True
    return False


def _transform(node, stats: dict) -> None:
    """Recursively rewrite `node` in place. `stats` accumulates change counts."""
    if isinstance(node, dict):
        # 1) Drop nullable properties from `required` BEFORE their schemas are
        #    rewritten (the rewrite erases the null marker we test for here).
        properties = node.get("properties")
        required = node.get("required")
        if isinstance(properties, dict) and isinstance(required, list):
            kept = [r for r in required if not _schema_is_nullable(properties.get(r, {}))]
            if len(kept) != len(required):
                stats["required_relaxed"] += len(required) - len(kept)
            if kept:
                node["required"] = kept
            else:
                node.pop("required", None)

        # 2) Collapse nullable anyOf/oneOf unions into their non-null schema.
        for keyword in ("anyOf", "oneOf"):
            branches = node.get(keyword)
            if isinstance(branches, list) and any(_is_null_branch(b) for b in branches):
                non_null = [b for b in branches if not _is_null_branch(b)]
                stats["nullable_unions_collapsed"] += 1
                if len(non_null) == 1:
                    # Inline the lone remaining schema, keeping sibling keywords
                    # (description, etc.) that lived alongside the union.
                    merged = dict(non_null[0])
                    for key, value in node.items():
                        if key == keyword:
                            continue
                        merged.setdefault(key, value)
                    node.clear()
                    node.update(merged)
                elif non_null:
                    node[keyword] = non_null

        # 3) Collapse OpenAPI 3.1 `type: [..., "null"]` arrays.
        type_value = node.get("type")
        if isinstance(type_value, list):
            non_null_types = [t for t in type_value if t != "null"]
            if len(non_null_types) != len(type_value):
                node["type"] = non_null_types[0] if len(non_null_types) == 1 else non_null_types

        # 4) Relax strict additionalProperties for forward-compatibility. Runs
        #    after the union collapse above, which can inline an object schema
        #    that carried its own `additionalProperties: false`.
        if node.get("additionalProperties") is False:
            del node["additionalProperties"]
            stats["additional_properties_removed"] += 1

        for value in list(node.values()):
            _transform(value, stats)
    elif isinstance(node, list):
        for item in node:
            _transform(item, stats)


def patch_spec(filepath: str) -> None:
    """Patch the OpenAPI document at `filepath` in place."""
    with open(filepath, "r") as f:
        spec = json.load(f)

    stats = {
        "nullable_unions_collapsed": 0,
        "required_relaxed": 0,
        "additional_properties_removed": 0,
    }
    _transform(spec, stats)

    with open(filepath, "w") as f:
        json.dump(spec, f, indent=4)

    if any(stats.values()):
        print(
            "Patched spec: "
            f"{stats['nullable_unions_collapsed']} nullable unions collapsed, "
            f"{stats['required_relaxed']} required fields relaxed, "
            f"{stats['additional_properties_removed']} additionalProperties:false removed"
        )
    else:
        print("No schemas needed patching")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: patch-openapi-spec.py <path-to-openapi.json>")
        sys.exit(1)

    patch_spec(sys.argv[1])
