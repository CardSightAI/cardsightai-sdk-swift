# CardSight AI Swift SDK

![Swift Version](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%2B%20%7C%20macOS%2012%2B-blue)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![API Coverage](https://img.shields.io/badge/API_Coverage-100%25-success)](audit-results/AUDIT-SUMMARY.md)

**Official Swift SDK for [CardSight AI](https://cardsight.ai) REST API**

The most comprehensive baseball card identification and collection management platform.
**2M+ Cards** • **AI-Powered Recognition** • **Free Tier Available**

**Quick Links:** [Getting Started](#getting-started) • [Installation](#installation) • [Examples](#usage-examples) • [Documentation](https://api.cardsight.ai/documentation) • [Support](#support)

---

## Features

- **Full Swift Concurrency Support** - Built with async/await for modern Swift development
- **Type-Safe API** - Auto-generated types from OpenAPI specification
- **Automatic HEIC Conversion** - Seamlessly handles iPhone's default photo format
- **Smart Image Processing** - Automatic resizing and compression for optimal uploads
- **Platform Support** - Native support for iOS, macOS, tvOS, and watchOS
- **Comprehensive Error Handling** - Detailed error types with retry capabilities
- **100% API Coverage** - All CardSight AI endpoints are fully implemented

## Key Capabilities

| Feature | Description |
|---------|-------------|
| **Card Identification** | Identify cards from images using AI with automatic HEIC to JPEG conversion |
| **Catalog Search** | Search 2M+ baseball cards database |
| **Collections** | Manage owned card collections with analytics |
| **Collectors** | Manage collector profiles |
| **Lists** | Track wanted cards (wishlists) |
| **Grading** | PSA, BGS, SGC grade information |
| **AI Search** | Natural language queries |
| **Autocomplete** | Search suggestions |

## Requirements

- Swift 5.9+
- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- API Key from [cardsight.ai](https://cardsight.ai) (free tier available)

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/cardsightai/cardsightai-sdk-swift.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/cardsightai/cardsightai-sdk-swift.git`
3. Click Add Package

## Getting Started

### Get Your Free API Key

Get started in minutes with a **free API key** from [cardsight.ai](https://cardsight.ai) - no credit card required!

### Quick Start (< 5 minutes)

```swift
import CardSightAI

// 1. Initialize the client
let client = try CardSightAI(apiKey: "your_api_key_here")

// 2. Identify a card from an image
let image: UIImage = // ... from camera or photo library
let result = try await client.identify.card(image)

// 3. Access the identification results
switch result {
case .ok(let response):
    switch response.body {
    case .json(let identification):
        print("Card: \(identification.card?.name ?? "Unknown")")
        print("Confidence: \(identification.confidence)%")
    }
default:
    print("Identification failed")
}
```

That's it! The SDK handles HEIC conversion, image optimization, and API communication automatically.

## Usage Examples

### Card Identification with HEIC Support

The SDK automatically handles HEIC images from iPhone cameras:

```swift
import UIKit
import CardSightAI

let client = try CardSightAI(apiKey: "your_api_key")

// From camera or photo library (HEIC automatically converted to JPEG)
let image: UIImage = // ... from UIImagePickerController
let result = try await client.identify.card(image)

// The SDK automatically:
// 1. Detects if the image is HEIC format
// 2. Converts HEIC to JPEG
// 3. Resizes if needed (max 2048x2048 by default)
// 4. Optimizes file size (max 5MB)
// 5. Sends to API

print("Identified card: \(result)")
```

### Custom Image Processing Options

```swift
// Configure custom image processing
let config = try CardSightAIConfig(
    apiKey: "your_api_key",
    imageProcessing: ImageProcessingOptions(
        maxDimension: 1024,      // Smaller size for faster uploads
        jpegQuality: 0.7,        // Lower quality for smaller files
        maxFileSizeMB: 3.0,      // Max 3MB
        correctOrientation: true  // Fix orientation issues
    )
)

let client = try CardSightAI(config: config)
```

### Handling Different Image Sources

```swift
// From Data (auto-detects format)
let imageData: Data = // ... image data
let result = try await client.identify.card(imageData)

// From file URL
let fileURL = URL(fileURLWithPath: "/path/to/image.heic")
let result = try await client.identify.card(fileURL)

// From NSImage (macOS)
#if canImport(AppKit)
let nsImage: NSImage = // ... your image
let result = try await client.identify.card(nsImage)
#endif
```

### Catalog Operations

```swift
// Search for cards with query parameters
var query = Operations.get_sol_v1_sol_catalog_sol_cards.Input.Query()
query.name = "Aaron Judge"
query.year = 2023
query.take = 10

let cards = try await client.catalog.cards.list(query: query)

// Get specific card
let card = try await client.catalog.cards.get(id: "card_uuid")

// Search sets
var setsQuery = Operations.get_sol_v1_sol_catalog_sol_sets.Input.Query()
setsQuery.year = 2023
setsQuery.take = 20

let sets = try await client.catalog.sets.list(query: setsQuery)

// Get specific set with details
let set = try await client.catalog.sets.get(id: "set_uuid")

// Get cards in a set
let setCards = try await client.catalog.sets.cards(id: "set_uuid")

// Search releases
var releasesQuery = Operations.get_sol_v1_sol_catalog_sol_releases.Input.Query()
releasesQuery.name = "Chrome"
releasesQuery.yearFrom = 2020
releasesQuery.yearTo = 2024

let releases = try await client.catalog.releases.list(query: releasesQuery)

// Get manufacturers
let manufacturers = try await client.catalog.manufacturers()

// Get segments (Baseball, Pokemon, etc.)
let segments = try await client.catalog.segments()

// Get parallels
let parallels = try await client.catalog.parallels()

// Get catalog statistics
let stats = try await client.catalog.statistics()
```

### Collection Management

```swift
// Create a collection
let collection = try await client.collections.create(
    name: "My Vintage Cards",
    description: "Pre-1980 baseball cards",
    collectorId: "collector_uuid"
)

// Add card to collection
try await client.collections.cards.add(
    collectionId: collection.id,
    cardId: "card_uuid",
    quantity: 1,
    buyPrice: "50.00",
    buyDate: "2024-01-15"
)

// Get collection analytics
let analytics = try await client.collections.analytics(collectionId: collection.id)
print("Total value: \(analytics.totalValue)")
```

### Image Retrieval

Retrieve card images directly as platform-native image types or raw data:

```swift
#if canImport(UIKit)
// Get card image as UIImage (iOS/tvOS/watchOS)
let cardImage = try await client.images.getCardImage(id: "card_uuid")
imageView.image = cardImage

// Or get raw JPEG data
let imageData = try await client.images.getCardData(id: "card_uuid", format: "raw")
#endif

#if canImport(AppKit)
// Get card image as NSImage (macOS)
let cardImage = try await client.images.getCardImage(id: "card_uuid")
imageView.image = cardImage
#endif

// Get base64-encoded image (format: "json")
let imageData = try await client.images.getCardData(id: "card_uuid", format: "json")
```

### Error Handling

```swift
do {
    let result = try await client.catalog.cards.get(id: "invalid_id")
} catch let error as CardSightAIError {
    switch error {
    case .authenticationError(let message):
        print("Auth failed: \(message)")
    case .apiError(let statusCode, let message, _):
        print("API error \(statusCode): \(message)")
    case .imageProcessingError(let message):
        print("Image processing failed: \(message)")
    case .networkError(let error):
        print("Network error: \(error)")
    case .timeout:
        print("Request timed out")
    default:
        print("Error: \(error.localizedDescription)")
    }

    // Check if retryable
    if error.isRetryable {
        // Retry logic
    }
}
```

## Image Processing Features

The SDK includes powerful image processing capabilities specifically designed for trading card images:

### Automatic HEIC Conversion

```swift
// iPhone camera photos (HEIC) are automatically converted
let photo = // ... from camera
let result = try await client.identify.card(photo) // Handles HEIC → JPEG
```

### Manual Image Processing

```swift
// Process image manually if needed
let processor = ImageProcessor()
let processedData = try await processor.processForUpload(image)

// Or with custom options
let customOptions = ImageProcessingOptions(
    maxDimension: 1024,
    jpegQuality: 0.6
)
let processedData = try await processor.processForUpload(image, customOptions: customOptions)
```

### Disable Auto-Processing

```swift
// If you want to handle image processing yourself
let config = try CardSightAIConfig(
    apiKey: "your_api_key",
    autoProcessImages: false  // Disable automatic processing
)
```

## Configuration

```swift
let config = try CardSightAIConfig(
    apiKey: "your_api_key",                    // Required
    baseURL: "https://api.cardsight.ai",       // Optional custom endpoint
    timeout: 30,                               // Request timeout in seconds
    customHeaders: ["X-Custom": "value"],      // Additional headers
    imageProcessing: ImageProcessingOptions(   // Image processing settings
        maxDimension: 2048,
        jpegQuality: 0.8,
        maxFileSizeMB: 5.0,
        correctOrientation: true
    ),
    autoProcessImages: true                    // Auto-convert HEIC
)

let client = try CardSightAI(config: config)
```

## API Endpoint Coverage

✅ **100% Coverage Verified**

The SDK provides complete coverage of all **76 CardSight AI REST API endpoints**:

| Category | Endpoints | Coverage | SDK Access |
|----------|-----------|----------|------------|
| **Health** | 2 | 100% | `client.health.*` |
| **Card Identification** | 1 | 100% | `client.identify.*` |
| **Catalog** | 14 | 100% | `client.catalog.*` |
| **Collections** | 23 | 100% | `client.collections.*` |
| **Collection Images** | 3 | 100% | `client.collections.cards.*` |
| **Collectors** | 5 | 100% | `client.collectors.*` |
| **Lists** | 8 | 100% | `client.lists.*` |
| **Grades** | 3 | 100% | `client.grades.*` |
| **Autocomplete** | 6 | 100% | `client.autocomplete.*` |
| **AI** | 1 | 100% | `client.ai.*` |
| **Images** | 1 | 100% | `client.images.*` |
| **Feedback** | 8 | 100% | `client.feedback.*` |
| **Subscription** | 1 | 100% | `client.subscription.*` |
| **TOTAL** | **76** | **100%** | - |

### Special Implementations

The SDK includes **3 manual implementations** for endpoints with incomplete OpenAPI schemas:

- 🔧 **POST /v1/identify/card** - Manual multipart upload with HEIC support
- 🔧 **POST /v1/collection/{collectionId}/cards/{cardId}/image** - Manual multipart upload with HEIC support
- 🔧 **GET /v1/images/cards/{id}** - Manual binary data extraction with platform-specific image types

## Building from Source

```bash
# Clone the repository
git clone https://github.com/cardsightai/cardsightai-sdk-swift.git
cd cardsightai-sdk-swift

# Update OpenAPI specification
make update-spec

# Build the package
make build

# Run tests (requires Xcode, not just Command Line Tools)
make test
```

## Testing

The SDK includes comprehensive unit tests and integration tests:

### Unit Tests

Unit tests validate SDK configuration, error handling, and image processing without requiring API connectivity:

```bash
swift test --filter CardSightAITests
```

### Integration Tests

The SDK includes integration tests that validate real API connectivity:

**Requirements:**
- **Xcode** (full installation, not just Command Line Tools)
- **API Key**: Set `CARDSIGHTAI_API_KEY` environment variable

**Available Tests:**

1. **Unauthenticated Health Check** (`GET /health`) - Tests basic API connectivity (no API key needed)
2. **Authenticated Health Check** (`GET /health/auth`) - Tests API connectivity and validates your API key

**Running Integration Tests:**

**In Xcode (Recommended):**

1. Open `Package.swift` in Xcode
2. Set `CARDSIGHTAI_API_KEY` in your scheme's environment variables (for authenticated test)
3. Run tests via Product → Test (⌘U)

**Via Command Line:**

```bash
# Run all integration tests (requires Xcode installation)
export CARDSIGHTAI_API_KEY=your_api_key_here
swift test --filter CardSightAIIntegrationTests

# Run individual tests
swift test --filter testHealthCheckUnauthenticated  # No API key needed
swift test --filter testHealthCheckAuthenticated     # Requires API key
```

**Note:**
- Integration tests require **Xcode** (not just Command Line Tools) due to XCTest framework dependencies
- Tests automatically skip when running in CI environments
- The unauthenticated health test works without an API key

## Troubleshooting

### Common Issues

#### "no such module 'XCTest'" when running tests

**Problem**: Tests fail with "no such module 'XCTest'" error
**Cause**: XCTest framework requires full Xcode installation, not just Command Line Tools
**Solution**: Install Xcode from the App Store and run tests from Xcode or ensure Xcode is selected as the active developer directory:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### "Authentication Error: API key is required"

**Problem**: Client initialization fails with authentication error
**Cause**: No API key provided and `CARDSIGHTAI_API_KEY` environment variable not set
**Solutions**:

```swift
// Option 1: Pass API key directly
let client = try CardSightAI(apiKey: "your_api_key")

// Option 2: Set environment variable
// In Xcode: Edit Scheme → Run → Arguments → Environment Variables
// Add: CARDSIGHTAI_API_KEY = your_api_key

// In Terminal:
export CARDSIGHTAI_API_KEY=your_api_key
```

#### Image Processing Fails with HEIC Images

**Problem**: HEIC images from iPhone camera fail to process
**Cause**: Image processor configuration or unsupported format
**Solutions**:

```swift
// Ensure auto-processing is enabled (default)
let client = try CardSightAI(
    apiKey: "your_api_key",
    autoProcessImages: true  // This is the default
)

// Or manually convert before uploading
if let jpegData = image.jpegData(compressionQuality: 0.8) {
    let result = try await client.identify.card(jpegData)
}
```

#### "Invalid Input: Invalid base URL"

**Problem**: Client initialization fails with invalid URL error
**Cause**: Malformed base URL string
**Solution**: Use the default URL or ensure custom URL is properly formatted:

```swift
// Use default (recommended)
let client = try CardSightAI(apiKey: "your_api_key")

// Or provide valid custom URL
let client = try CardSightAI(
    apiKey: "your_api_key",
    baseURL: "https://custom.api.url"
)
```

#### Request Timeout Errors

**Problem**: Requests fail with timeout errors
**Cause**: Network issues or slow connection
**Solutions**:

```swift
// Increase timeout for slow connections
let client = try CardSightAI(
    apiKey: "your_api_key",
    timeout: 60  // 60 seconds instead of default 30
)

// Check if error is retryable
do {
    let result = try await client.identify.card(image)
} catch let error as CardSightAIError {
    if error.isRetryable {
        // Retry the request
        print("Request failed but is retryable")
    }
}
```

#### Large Image Upload Fails

**Problem**: Image uploads fail or take too long
**Cause**: Image file size exceeds limits or is too large
**Solutions**:

```swift
// Reduce image size and quality
let config = try CardSightAIConfig(
    apiKey: "your_api_key",
    imageProcessing: ImageProcessingOptions(
        maxDimension: 1024,     // Smaller than default 2048
        jpegQuality: 0.6,       // Lower than default 0.8
        maxFileSizeMB: 2.0      // Smaller than default 5.0
    )
)
let client = try CardSightAI(config: config)
```

#### Ugly Auto-Generated Type Names

**Problem**: Working with types like `Operations.get_sol_v1_sol_catalog_sol_cards` is cumbersome
**Explanation**: These are auto-generated from the OpenAPI specification and reflect the API's internal structure
**Recommendation**: Use the convenience properties on the client which provide cleaner interfaces:

```swift
// Instead of using Operations types directly:
// var query = Operations.get_sol_v1_sol_catalog_sol_cards.Input.Query()

// Use the client's methods which hide the complexity:
let cards = try await client.catalog.cards.list(query: query)
```

### Getting Help

If you encounter issues not covered here:

1. **Check the API Documentation**: [api.cardsight.ai/documentation](https://api.cardsight.ai/documentation)
2. **Review Error Messages**: CardSightAI errors include detailed descriptions
   ```swift
   catch let error as CardSightAIError {
       print("Error: \(error.errorDescription ?? "Unknown")")
       print("Reason: \(error.failureReason ?? "Unknown")")
   }
   ```
3. **Enable Debug Logging**: Check network requests and responses
4. **Submit an Issue**: [GitHub Issues](https://github.com/cardsightai/cardsightai-sdk-swift/issues)
5. **Contact Support**: support@cardsight.ai

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT

## Support

- **Email**: support@cardsight.ai
- **Website**: [cardsight.ai](https://cardsight.ai)
- **API Documentation**: [api.cardsight.ai/documentation](https://api.cardsight.ai/documentation)
- **Issues**: [GitHub Issues](https://github.com/cardsightai/cardsightai-sdk-swift/issues)

## Acknowledgments

This SDK uses:
- [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator) for auto-generating API types
- [Swift OpenAPI Runtime](https://github.com/apple/swift-openapi-runtime) for API client functionality

*Made with ❤️ by CardSight AI, Inc.*
