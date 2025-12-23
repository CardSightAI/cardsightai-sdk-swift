#!/usr/bin/env python3
"""
Patches OpenAPI spec for forward-compatibility.

Apple's swift-openapi-generator strictly enforces additionalProperties: false
constraints. When the CardSight API returns new fields not yet in the spec,
this causes decoding failures.

The maintainers of swift-openapi-generator officially recommend preprocessing
the OpenAPI document for forward-compatibility:
https://github.com/apple/swift-openapi-generator/issues/608

This script removes additionalProperties: false from identification-related
schemas, allowing the SDK to gracefully ignore unknown fields in API responses.
"""
import json
import sys

# Schemas that should allow unknown properties for forward-compatibility
SCHEMAS_TO_PATCH = [
    "AIIdentificationInput",
    "IdentificationDataInput",
    "CardDetailsInput",
    "IdentifyCardResponseInput",
]


def patch_spec(filepath: str) -> None:
    """
    Patches the OpenAPI spec to remove additionalProperties: false
    from identification-related schemas.

    Args:
        filepath: Path to the openapi.json file
    """
    with open(filepath, 'r') as f:
        spec = json.load(f)

    schemas = spec.get("components", {}).get("schemas", {})
    patched = []

    for schema_name in SCHEMAS_TO_PATCH:
        if schema_name in schemas:
            schema = schemas[schema_name]
            if schema.get("additionalProperties") == False:
                del schema["additionalProperties"]
                patched.append(schema_name)

    with open(filepath, 'w') as f:
        json.dump(spec, f, indent=4)

    if patched:
        print(f"Patched schemas: {', '.join(patched)}")
    else:
        print("No schemas needed patching")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: patch-openapi-spec.py <path-to-openapi.json>")
        sys.exit(1)

    patch_spec(sys.argv[1])
