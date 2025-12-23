.PHONY: update-spec build test clean

# Update the OpenAPI specification from the API
update-spec:
	@echo "Fetching latest OpenAPI specification..."
	@curl -s https://api.cardsight.ai/documentation/json | python3 -m json.tool > Sources/CardSightAI/openapi.json
	@echo "Patching spec for forward-compatibility..."
	@python3 Scripts/patch-openapi-spec.py Sources/CardSightAI/openapi.json
	@echo "OpenAPI specification updated successfully!"

# Build the Swift package
build:
	swift build

# Run tests
test:
	swift test

# Clean build artifacts
clean:
	swift package clean
	rm -rf .build

# Generate documentation
docs:
	swift package generate-documentation

# Format code
format:
	swift-format --in-place --recursive Sources/ Tests/

# Lint code
lint:
	swift-format lint --recursive Sources/ Tests/