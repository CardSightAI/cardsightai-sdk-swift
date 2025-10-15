# Contributing to CardSight AI Swift SDK

Thank you for your interest in contributing to the CardSight AI Swift SDK! We welcome contributions from the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Code Style](#code-style)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to a code of conduct that promotes respect and inclusivity. By participating, you are expected to uphold this code. Please report unacceptable behavior to support@cardsight.ai.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/cardsightai-sdk-swift.git
   cd cardsightai-sdk-swift
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/cardsightai/cardsightai-sdk-swift.git
   ```

## Development Setup

### Prerequisites

- **Xcode 15.0+** (full installation, not just Command Line Tools)
- **Swift 5.9+**
- **Git**
- **API Key** from [cardsight.ai](https://cardsight.ai) for testing

### Building the SDK

```bash
# Build the package
swift build

# Or use make
make build
```

### Running Tests

```bash
# Run all tests
swift test

# Run only unit tests
swift test --filter CardSightAITests

# Run integration tests (requires CARDSIGHTAI_API_KEY)
export CARDSIGHTAI_API_KEY=your_api_key_here
swift test --filter CardSightAIIntegrationTests
```

## Making Changes

### Branch Naming

Create a descriptive branch name:
- `feature/add-xyz` - For new features
- `fix/issue-123` - For bug fixes
- `docs/improve-readme` - For documentation changes
- `refactor/simplify-abc` - For code refactoring

### Commit Messages

Write clear, descriptive commit messages:

```
Add support for custom timeout configuration

- Allow developers to configure request timeouts
- Update documentation with timeout examples
- Add tests for timeout behavior
```

**Format:**
- First line: Brief summary (50 chars or less)
- Blank line
- Detailed description with bullet points if needed

### Code Organization

- **Sources/CardSightAI/** - Main SDK code
  - `CardSightAI.swift` - Main client and core APIs
  - `Configuration.swift` - Configuration types
  - `Errors.swift` - Error definitions
  - `API/` - Endpoint-specific implementations
  - `ImageProcessing/` - Image handling utilities
- **Tests/** - All test code
- **README.md** - Main documentation
- **CHANGELOG.md** - Version history

## Testing

### Test Requirements

All contributions must include appropriate tests:

1. **Unit Tests** - Required for all new functionality
   - Test public API surfaces
   - Test error conditions
   - Test edge cases

2. **Integration Tests** - Required for new endpoints
   - Test real API connectivity
   - Validate response parsing
   - Handle authentication scenarios

3. **Documentation Tests** - Ensure examples compile
   - All README code examples must compile
   - DocC documentation must build without warnings

### Writing Tests

```swift
// Unit test example
func testNewFeature() throws {
    let config = try CardSightAIConfig(apiKey: "test_key")
    let client = try CardSightAI(config: config)

    // Test your feature
    XCTAssertNotNil(client.newFeature)
}

// Integration test example
func testNewEndpoint() async throws {
    try XCTSkipIf(ProcessInfo.processInfo.environment["CI"] != nil,
                  "Skipping integration test in CI")

    guard let apiKey = ProcessInfo.processInfo.environment["CARDSIGHTAI_API_KEY"] else {
        throw XCTSkip("Set CARDSIGHTAI_API_KEY to run this test")
    }

    let client = try CardSightAI(apiKey: apiKey)
    let result = try await client.newEndpoint.call()

    // Verify result
    XCTAssertNotNil(result)
}
```

## Submitting Changes

### Pull Request Process

1. **Update your branch** with the latest upstream changes:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests** to ensure everything passes:
   ```bash
   make test
   ```

3. **Update documentation**:
   - Update README.md if adding new features
   - Update CHANGELOG.md under `[Unreleased]`
   - Add inline documentation for public APIs

4. **Push your branch**:
   ```bash
   git push origin your-branch-name
   ```

5. **Create a Pull Request** on GitHub:
   - Provide a clear title and description
   - Reference any related issues
   - Include screenshots/examples if applicable
   - Check the "Allow edits from maintainers" box

### Pull Request Checklist

- [ ] Code builds successfully (`make build`)
- [ ] All tests pass (`make test`)
- [ ] New code has appropriate test coverage
- [ ] Public APIs have documentation comments
- [ ] README.md updated (if applicable)
- [ ] CHANGELOG.md updated under `[Unreleased]`
- [ ] No compiler warnings
- [ ] Code follows project style guidelines

## Code Style

### Swift Style Guidelines

- **Follow Swift API Design Guidelines**: https://swift.org/documentation/api-design-guidelines/
- **Use meaningful names**: Prefer clarity over brevity
- **Document public APIs**: All public types, methods, and properties must have documentation comments
- **Use modern Swift features**: async/await, type inference, optionals
- **Avoid force unwrapping**: Use guard/if-let or provide clear error messages

### Documentation Comments

```swift
/// Brief one-line description of the method
///
/// Longer description providing more context about what this method does,
/// when to use it, and any important considerations.
///
/// - Parameters:
///   - param1: Description of first parameter
///   - param2: Description of second parameter
/// - Returns: Description of what is returned
/// - Throws: Description of errors that can be thrown
///
/// # Example
/// ```swift
/// let result = try await client.method(param1: "value", param2: 42)
/// ```
public func method(param1: String, param2: Int) async throws -> Result {
    // Implementation
}
```

### Formatting

- **Indentation**: 4 spaces (no tabs)
- **Line length**: Aim for 100 characters max
- **Braces**: Opening brace on same line
- **Whitespace**: Blank line between methods, logical sections

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Description**: Clear description of the issue
2. **Environment**:
   - SDK version
   - Xcode version
   - iOS/macOS version
   - Swift version
3. **Steps to reproduce**:
   ```swift
   let client = try CardSightAI(apiKey: "...")
   // Code that demonstrates the issue
   ```
4. **Expected behavior**: What you expected to happen
5. **Actual behavior**: What actually happened
6. **Error messages**: Full error messages and stack traces

### Feature Requests

When requesting features, please provide:

1. **Use case**: Describe the problem you're trying to solve
2. **Proposed solution**: How you envision the feature working
3. **Alternatives considered**: Other approaches you've thought about
4. **API example**: Show how you'd like to use the feature
   ```swift
   // Example of proposed API
   let result = try await client.newFeature.doSomething()
   ```

## Questions?

- **Email**: support@cardsight.ai
- **Issues**: [GitHub Issues](https://github.com/cardsightai/cardsightai-sdk-swift/issues)
- **Documentation**: [API Docs](https://api.cardsight.ai/documentation)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to CardSight AI Swift SDK! 🎉
