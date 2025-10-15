# Changelog

All notable changes to the CardSight AI Swift SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-15

### Added
- Initial release of CardSight AI Swift SDK
- Full Swift concurrency support with async/await
- Auto-generated types from OpenAPI specification
- Automatic HEIC to JPEG conversion for iPhone photos
- Smart image processing with automatic resizing and compression
- Platform support for iOS 15+, macOS 12+, tvOS 15+, and watchOS 8+
- Comprehensive error handling with detailed error types
- 100% API coverage (76 endpoints across 13 categories)
- Integration tests for health check endpoints
- Comprehensive unit tests

### API Coverage
- Health check endpoints (2)
- Card identification with image upload (1)
- Catalog search and browsing (14)
- Collection management (23)
- Collection card images (3)
- Collector profiles (5)
- Wishlist management (8)
- Grading information (3)
- Autocomplete (6)
- AI-powered search (1)
- Image retrieval (1)
- Feedback submission (8)
- Subscription management (1)

### Features
- **Health**: Unauthenticated and authenticated health checks
- **Identify**: Multi-format image upload (UIImage, NSImage, Data, URL) with automatic processing
- **Catalog**: Search cards, sets, releases, manufacturers, segments, parallels, and statistics
- **Collections**: Full CRUD operations with analytics
- **Collectors**: Profile management
- **Lists**: Wishlist creation and management
- **Grades**: PSA, BGS, SGC grade information lookup
- **Autocomplete**: Search suggestions for cards, players, sets, and more
- **AI**: Natural language query support
- **Images**: Platform-native image retrieval (UIImage/NSImage)
- **Feedback**: Submit feedback on identifications and search results
- **Subscription**: Subscription status and management

### Developer Experience
- Type-safe API with full OpenAPI type generation
- Configurable image processing options
- Automatic HEIC conversion
- Environment variable support for API keys
- Comprehensive error types with retry detection
- Detailed inline documentation
- Integration tests for easy API validation

### Special Implementations
- Manual multipart form-data upload for card identification (OpenAPI schema limitation)
- Manual image upload for collection cards (OpenAPI schema limitation)
- Platform-specific binary image retrieval (OpenAPI schema limitation)

[Unreleased]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/cardsightai/cardsightai-sdk-swift/releases/tag/v1.0.0
