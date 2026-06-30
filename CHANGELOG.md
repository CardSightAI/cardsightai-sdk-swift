# Changelog

All notable changes to the CardSight AI Swift SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2026-06-30

### Added
- **2 new search endpoints** (94 → 96 operations), all available via `client.raw.{operationId}()`:
  - **Pricing** — `searchPricingByTitle` (`GET /v1/pricing/search`): free-text fuzzy search over marketplace listing titles for historical bid/ask pricing, including raw listings never matched to a canonical card. Params: `q` (required, 3–300 chars), `period` (e.g. `"7d"`/`"3m"`/`"1y"`/`"all"`), `listing_type` (`auction`/`fixed`/`both`), `limit` (≤500). Returns `PricingSearchResponse` (`query`, `results`, `meta`).
  - **Marketplace** — `searchMarketplaceByTitle` (`GET /v1/marketplace/search`): free-text fuzzy search over titles of currently active listings. Params: `q` (required, 3–300 chars), `listing_type`, `limit` (≤500). Returns `MarketplaceSearchResponse` (`query`, `results`, `meta`).
- New auto-generated response models: `PricingSearchResponse`/`PricingSearchRecord`/`PricingSearchQueryEcho`, `MarketplaceSearchResponse`/`MarketplaceSearchRecord`/`MarketplaceSearchQueryEcho`, `SearchMeta`, and shared `SearchMatchedCard`/`SearchGrade`/`CardSetContext`.

### Changed
- **`Segment`** now exposes an optional `shortname` (URL-friendly segment key, e.g. `"magic"`) usable with `identify.cardBySegment`. Additive, non-breaking.
- Pricing/marketplace descriptions reworded to the bid (completed auction sales) / ask (Buy It Now asking prices) framing; `PricingCardContext.set` now shares the `CardSetContext` model. Wire format unchanged.

## [2.2.0] - 2026-06-03

### Added
- **15 new API endpoints** (79 → 94 operations), all available via `client.raw.{operationId}()`:
  - **Pricing** — `getCardPricing` (completed-sales history with parallel/grade/period filters) and `getBulkPricing` (POST, multiple cards at once)
  - **Marketplace** — `getCardMarketplace` (active listings)
  - **Population** — `getCardPopulation`, `getSetPopulation`, `getReleasePopulation` (graded population reports)
  - **Release Calendar** — `getReleaseCalendar` (upcoming releases with pre-order dates)
  - **Catalog Search** — `searchCatalog` (global fuzzy search across cards/sets/releases/parallels)
  - **Fields** — `getFields`, `getFieldById` (cross-TCG metadata fields)
  - **Parallels** — `getParallel` (parallel detail by id)
  - **Card Detection** — `detectCard` (lightweight presence check)
  - **Segment Identification** — `identifyCardBySegment` (scope identification to a known segment)
  - **Set Identifiability** — `listIdentifiableSets`, `checkSetIdentifiable` (quota-free pre-flight checks)
- **`client.detect.card(_:)`** convenience helper for lightweight card-presence detection, with the same automatic image processing (HEIC conversion, resizing, optimization) as `identify.card`. Accepts `UIImage`/`NSImage`/`Data`/`URL`.
- **`client.identify.cardBySegment(_:segment:)`** convenience helper to scope identification to a known segment (e.g. `"baseball"`). Accepts `UIImage`/`NSImage`/`Data`/`URL`.
- **`ImageProcessor.prepareForUpload(_:optimized:autoProcess:)`** — public helper that centralizes the standard optimize/process/raw upload policy used by all image-upload endpoints.

### Fixed
- **HEIC orientation** — HEIC images are now rotated upright based on their EXIF/container orientation metadata during JPEG conversion. Previously `CGImageSourceCreateImageAtIndex` discarded the orientation tag, so rotated iPhone camera photos could upload sideways or upside-down. Decoding now uses `CGImageSourceCreateThumbnailAtIndex` with `kCGImageSourceCreateThumbnailWithTransform`, baking the orientation into the pixels at full resolution (ImageIO only, so it works on iOS, macOS, tvOS, and watchOS).
- **Dropped nullable fields** — Response fields modeled as `anyOf: [<schema>, {type: null}]` (the OpenAPI 3.1 nullable idiom the API now emits) were being silently dropped by swift-openapi-generator, so types like `PricingRecord`, `MarketplaceRecord`, `ReleaseCalendarEntry`, and `PopulationGradeEntry` were missing most of their fields — and the strict `additionalProperties: false` on those objects made decoding real responses fail. The patch script now restores all 88 nullable fields as proper Swift optionals that correctly decode JSON `null`.

### Changed
- **`Scripts/patch-openapi-spec.py` generalized** — replaced the hand-maintained four-schema allow-list with two document-wide transforms: (1) collapse nullable `anyOf`/`oneOf` unions into optional non-null schemas (and relax the corresponding `required` entries), and (2) remove `additionalProperties: false` for forward-compatibility across all schemas. New endpoints are now handled automatically with no allow-list to maintain.
- **Tests** updated for the v2.0.0 client surface (the stale `client.health`/`client.catalog`/… wrapper references were removed) and the current health operations (`getHealth`/`getHealthAuthenticated`).

## [2.1.3] - 2025-12-22

### Fixed
- **Card Identification Content-Type Header**: Added missing `Content-Type: image/jpeg` header on multipart part
  - Uses `MultipartRawPart` for full header control instead of typed `MultipartPart`
  - Properly sets `Content-Disposition` and `Content-Type` headers required by the API

## [2.1.2] - 2025-12-22

### Fixed
- **Card Identification Upload Format**: Fixed `identifyCard` to use multipart/form-data instead of raw binary
  - The API now requires multipart/form-data for image uploads
  - Resolves "Invalid file upload" validation errors when identifying cards

## [2.1.1] - 2025-12-22

### Added
- **Image Endpoints Now Working**: API team fixed OpenAPI spec to include proper response content types
  - `getCardImage` - Now returns `image/jpeg` (binary) or `application/json` (base64 data URI) based on `format` parameter
  - `getCollectionCardImage` - Now returns `image/jpeg` binary data
  - `getCollectionCardImageThumbnail` - Now returns `image/jpeg` binary data
  - SDK consumers can now retrieve card images directly via these endpoints
- **OpenAPI Spec Patching Script**: New `Scripts/patch-openapi-spec.py` automatically patches identification schemas during `make update-spec`
  - Follows [Apple's official recommendation](https://github.com/apple/swift-openapi-generator/issues/608) for handling forward-compatibility with swift-openapi-generator
  - Patches `AIIdentificationInput`, `IdentificationDataInput`, `CardDetailsInput`, and `IdentifyCardResponseInput` schemas
- **Documentation**: Added "OpenAPI Spec Patching" section to README explaining the patching process and rationale

### Fixed
- **Forward-Compatibility for Card Identification**: Added automated OpenAPI spec patching to prevent decode errors when the API returns new fields
  - Resolves `DecodingError.dataCorrupted` errors caused by `additionalProperties: false` constraints on identification schemas
  - SDK now gracefully ignores unknown fields in API responses for identification endpoints

### Changed
- `make update-spec` now automatically runs the patch script after fetching the OpenAPI specification

## [2.0.0] - 2025-11-04

### Breaking Changes

**Major SDK Architecture Simplification** - This release removes the wrapper layer and provides direct access to the auto-generated OpenAPI client, resulting in a cleaner, more maintainable SDK.

#### What Changed
- **Removed all API wrapper classes** - The `Sources/CardSightAI/API/` directory has been deleted
- **Direct client access required** - All operations (except card identification) now accessed via `client.raw.{operationName}()`
- **Clean operation names** - Updated OpenAPI spec provides clean method names like `getCards()`, `createCollection()`, `getGradingCompanies()`

#### Migration Guide

**Before (v1.x):**
```swift
// Catalog operations
let cards = try await client.catalog.cards.list(query: query)
let card = try await client.catalog.cards.get(id: "card_uuid")

// Collection operations
let collection = try await client.collections.create(name: "My Cards", ...)
let analytics = try await client.collections.analytics(collectionId: id)

// Grades
let companies = try await client.grades.companies()
```

**After (v2.0):**
```swift
// Catalog operations
let cards = try await client.raw.getCards(query: query)
let card = try await client.raw.getCard(.init(path: .init(id: "card_uuid")))

// Collection operations
let input = Operations.createCollection.Input(body: .json(.init(name: "My Cards", ...)))
let collection = try await client.raw.createCollection(input)
let analytics = try await client.raw.getCollectionAnalytics(.init(path: .init(collectionId: id)))

// Grades
let companies = try await client.raw.getGradingCompanies()
```

**Card identification remains unchanged:**
```swift
// Still works the same in v2.0
let result = try await client.identify.card(image)
```

**Health checks now have shortcuts:**
```swift
// New convenience methods on main client
let health = try await client.getHealth()
let authHealth = try await client.getHealthAuthenticated()

// Or use the raw client
let health = try await client.raw.getHealth()
```

### Added
- **Random Catalog Endpoints**: Three new endpoints for pack opening simulations and discovery features (79 total endpoints)
  - `client.raw.getRandomReleases(query:)` - Get random releases matching filters
  - `client.raw.getRandomSets(query:)` - Get random sets matching filters
  - `client.raw.getRandomCards(query:)` - Get random cards with optional parallel odds system
- **Parallel Odds System**: Cards random endpoint includes sophisticated parallel conversion
  - Enable with `includeParallels=true` query parameter
  - Simulates pack opening with weighted probability for numbered parallels (/1, /10, /99, etc.)
  - Collective roll for unlimited parallels (Refractor, Rainbow, etc.)
  - Returns `isParallel`, `parallelId`, `parallelName`, and `numberedTo` fields for parallel cards
- Convenience methods `getHealth()` and `getHealthAuthenticated()` on main `CardSightAI` client

### Changed
- **All catalog, collection, grade, list, autocomplete, AI, image, feedback, and subscription operations** now accessed via `client.raw.{operationName}()`
- OpenAPI specification updated with proper `operationId` values for clean method names
- Reduced SDK complexity by hundreds of lines of wrapper code
- Updated all documentation and examples to reflect new API patterns

### Removed
- `CatalogAPI` wrapper class and all sub-classes (`CardsAPI`, `SetsAPI`, `ReleasesAPI`)
- `CollectionsAPI` wrapper class and `CollectionCardsAPI` sub-class
- `CollectorsAPI` wrapper class
- `ListsAPI` wrapper class and `ListCardsAPI` sub-class
- `GradesAPI` wrapper class
- `AutocompleteAPI` wrapper class
- `AIAPI` wrapper class
- `ImagesAPI` wrapper class
- `FeedbackAPI` wrapper class
- `SubscriptionAPI` wrapper class
- `HealthAPI` wrapper class (replaced with convenience methods on main client)

### Technical Details
- Entire `Sources/CardSightAI/API/` directory removed
- `IdentifyAPI` retained as the only wrapper (provides image processing before API calls)
- All operation names cleaned up in OpenAPI spec (e.g., `get_sol_v1_sol_catalog_sol_cards` → `getCards`)
- SDK now leverages Swift OpenAPI Generator's clean, type-safe client directly
- Improved maintainability - API changes no longer require manual wrapper updates

### Benefits
- **Simpler architecture** - Direct access to auto-generated operations
- **Better type safety** - Use generated `Operations.{operationId}.Input` types directly
- **Easier maintenance** - No wrapper layer to keep in sync with API changes
- **Transparent API** - Clear mapping between SDK calls and REST endpoints
- **Smaller codebase** - Hundreds of lines of redundant code eliminated

## [1.3.0] - 2025-10-26 [DEPRECATED]

**Note**: This version was never released. Changes merged into v2.0.0.

### Added
- **Random Catalog Endpoints**: Three new endpoints for pack opening simulations and discovery features
  - `client.catalog.releases.random(query:)` - Get random releases matching filters
  - `client.catalog.sets.random(query:)` - Get random sets matching filters
  - `client.catalog.cards.random(query:)` - Get random cards with optional parallel odds system
- **Parallel Odds System**: Cards random endpoint includes sophisticated parallel conversion
  - Enable with `includeParallels=true` query parameter
  - Simulates pack opening with weighted probability for numbered parallels (/1, /10, /99, etc.)
  - Collective roll for unlimited parallels (Refractor, Rainbow, etc.)
  - Returns `isParallel`, `parallelId`, `parallelName`, and `numberedTo` fields for parallel cards
- All random endpoints support standard filters (year, manufacturer, segment, search)
- Count parameter (1-200) controls number of random results returned
- Duplicate-free results even when count exceeds available records

### Technical Details
- Added three wrapper methods to `CatalogAPI.swift` for clean SDK interface
- Auto-generated types from updated OpenAPI specification
- Database-level randomization (`ORDER BY RANDOM()`) for true random distribution
- `setId` and `releaseId` are mutually exclusive on cards endpoint (400 error if both specified)
- Comprehensive DocC documentation with usage examples for all three endpoints

## [1.2.0] - 2025-10-22

### Added
- **Image Upload Optimization**: New `optimized` parameter on all card identification methods to reduce upload times
  - Intelligently resizes images based on smallest dimension (900px) while maintaining aspect ratio
  - Applies 80% JPEG compression for optimal balance of quality and file size
  - Significantly reduces upload time on cellular networks without compromising identification accuracy
  - **Enabled by default** to optimize for cellular network performance
  - Enabled by default for all identification methods: `card(_ image:)`, `card(_ imageData:)`, `card(_ url:)`
  - If your use case is primarily WiFi-based, set `optimized: false` to upload high-resolution images (max dimension 2048px, standard compression)

### Changed
- **BEHAVIOR CHANGE**: Card identification now optimizes images by default for faster cellular uploads
  - Optimized for cellular network performance - reduces upload time and data usage
  - For WiFi-only use cases or when high-resolution images are required, pass `optimized: false` to any `card()` method
  - Configuration via `ImageProcessingOptions` still applies when `optimized: false`

### Technical Details
- New `optimizeForUpload()` methods in `ImageProcessor` for all input types (UIImage, NSImage, Data, URL)
- Optimization ensures smallest dimension is 900px with 80% JPEG quality
- HEIC conversion and orientation correction still applied during optimization
- Backward compatible: existing `processForUpload()` methods unchanged

## [1.1.0] - 2025-10-19

### Changed
- **BREAKING**: Updated Card Identification endpoint response structure to support multi-card detection
  - Response now includes `success: Bool`, `requestId: String`, `detections: [Detection]?`, and `processingTime: Double?`
  - Each detection in the `detections` array represents a separate physical card detected in the image
  - `confidence` is now an enum: `.High`, `.Medium`, or `.Low` (previously a percentage)
  - Updated OpenAPI specification to reflect new API contract

### Updated
- Updated README.md documentation with new identification response examples
- Added examples showing how to handle single and multiple card detections
- Added examples for accessing new response fields (`requestId`, `processingTime`)
- Clarified that `detections` array represents multiple physical cards, not ranked results

### Fixed
- Documentation now correctly reflects the Card Identification API response structure

### Notes
- **No SDK code changes required** - The implementation already uses auto-generated types from OpenAPI spec
- Existing code using the old response structure will need to be updated to access `identification.detections[].card` instead of `identification.card`

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

[2.3.0]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v2.1.3...v2.2.0
[2.1.3]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/cardsightai/cardsightai-sdk-swift/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/cardsightai/cardsightai-sdk-swift/releases/tag/v1.0.0
