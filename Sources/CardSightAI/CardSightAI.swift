import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

/// Main client for interacting with the CardSight AI API.
///
/// The `CardSightAI` client provides access to all CardSight AI REST API endpoints
/// including card identification, catalog search, collection management, and more.
///
/// # Example
/// ```swift
/// // Initialize with API key
/// let client = try CardSightAI(apiKey: "your_api_key_here")
///
/// // Or use environment variable CARDSIGHTAI_API_KEY
/// let client = try CardSightAI()
///
/// // Identify a card from an image
/// let result = try await client.identify.card(image)
///
/// // Use the raw client for all other operations
/// let cards = try await client.getCards(query: .init(search: "Bonds"))
/// let collections = try await client.getCollections()
/// ```
///
/// # Features
/// - Full Swift concurrency support with async/await
/// - Automatic HEIC to JPEG conversion for iPhone photos
/// - Smart image processing with automatic resizing and compression
/// - Type-safe API with auto-generated types
/// - Comprehensive error handling
///
/// # See Also
/// - ``CardSightAIConfig`` for configuration options
/// - ``CardSightAIError`` for error handling
public class CardSightAI {
    /// The configuration for this client instance
    public let config: CardSightAIConfig

    /// The underlying OpenAPI client
    private let client: Client

    /// Image processor for handling image uploads
    ///
    /// Provides direct access to image processing utilities for custom workflows.
    public let imageProcessor: ImageProcessor

    /// Card identification helper
    ///
    /// Provides convenient methods for identifying cards with automatic image processing.
    /// For direct API access, use the ``raw`` client.
    public lazy var identify = IdentifyAPI(client: self)

    /// Lightweight card-detection helper
    ///
    /// Provides a fast, low-cost presence check (`detect.card`) with the same automatic
    /// image processing as ``identify``. For direct API access, use the ``raw`` client.
    public lazy var detect = DetectAPI(client: self)

    /// Initialize the CardSightAI client with a configuration object.
    ///
    /// - Parameter config: Configuration for the client
    /// - Throws: ``CardSightAIError/invalidInput(_:)`` if the base URL is invalid
    ///
    /// # Example
    /// ```swift
    /// let config = try CardSightAIConfig(
    ///     apiKey: "your_api_key",
    ///     imageProcessing: ImageProcessingOptions(maxDimension: 1024)
    /// )
    /// let client = try CardSightAI(config: config)
    /// ```
    public init(config: CardSightAIConfig) throws {
        self.config = config
        self.imageProcessor = ImageProcessor(options: config.imageProcessing)

        // Create URL from base URL
        guard let url = URL(string: config.baseURL) else {
            throw CardSightAIError.invalidInput("Invalid base URL: \(config.baseURL)")
        }

        // Create middleware for authentication
        let authMiddleware = AuthenticationMiddleware(apiKey: config.apiKey)

        // Create timeout middleware
        let timeoutMiddleware = TimeoutMiddleware(timeout: config.timeout)

        // Configure transport
        let transport = URLSessionTransport(configuration: .init(
            session: .shared
        ))

        // Create the OpenAPI client
        self.client = Client(
            serverURL: url,
            transport: transport,
            middlewares: [authMiddleware, timeoutMiddleware]
        )
    }

    /// Convenience initializer for quick setup with individual parameters.
    ///
    /// This initializer provides a simpler way to create a client without manually
    /// constructing a ``CardSightAIConfig`` object. Most users will use this method.
    ///
    /// - Parameters:
    ///   - apiKey: API key for authentication. If `nil`, reads from `CARDSIGHTAI_API_KEY` environment variable
    ///   - baseURL: Base URL for the API (default: production API)
    ///   - timeout: Request timeout in seconds (default: 30)
    ///   - customHeaders: Additional HTTP headers to include with every request
    ///   - imageProcessing: Image processing configuration (default: optimized settings)
    ///   - autoProcessImages: Whether to automatically process images before upload (default: true)
    /// - Throws: ``CardSightAIError/authenticationError(_:)`` if no API key is provided or found
    /// - Throws: ``CardSightAIError/invalidInput(_:)`` if the base URL is invalid
    ///
    /// # Example
    /// ```swift
    /// // Simple initialization with API key
    /// let client = try CardSightAI(apiKey: "your_api_key")
    ///
    /// // Or use environment variable
    /// let client = try CardSightAI()
    ///
    /// // Custom configuration
    /// let client = try CardSightAI(
    ///     apiKey: "your_api_key",
    ///     timeout: 60,
    ///     imageProcessing: ImageProcessingOptions(maxDimension: 1024)
    /// )
    /// ```
    public convenience init(
        apiKey: String? = nil,
        baseURL: String = "https://api.cardsight.ai",
        timeout: TimeInterval = 30,
        customHeaders: [String: String] = [:],
        imageProcessing: ImageProcessingOptions = ImageProcessingOptions(),
        autoProcessImages: Bool = true
    ) throws {
        let config = try CardSightAIConfig(
            apiKey: apiKey,
            baseURL: baseURL,
            timeout: timeout,
            customHeaders: customHeaders,
            imageProcessing: imageProcessing,
            autoProcessImages: autoProcessImages
        )
        try self.init(config: config)
    }

    // MARK: - Convenience Methods

    /// Perform a basic health check without authentication
    /// - Returns: Health check response
    public func getHealth() async throws -> Operations.getHealth.Output {
        try await client.getHealth()
    }

    /// Perform an authenticated health check
    /// - Returns: Health check response with authentication confirmation
    public func getHealthAuthenticated() async throws -> Operations.getHealthAuthenticated.Output {
        try await client.getHealthAuthenticated()
    }

    // MARK: - Raw Client Access

    /// Direct access to the auto-generated OpenAPI client
    ///
    /// Use this to call any API endpoint directly with clean, type-safe methods.
    ///
    /// # Example
    /// ```swift
    /// // Catalog operations
    /// let cards = try await client.getCards(query: .init(search: "Bonds"))
    /// let sets = try await client.getSets(query: .init(year: 1989))
    ///
    /// // Collection operations
    /// let collections = try await client.getCollections()
    /// let newCollection = try await client.createCollection(body: .json(...))
    ///
    /// // Grading operations
    /// let companies = try await client.getGradingCompanies()
    /// ```
    ///
    /// All 94 API operations are available as methods on this client with clean names like:
    /// - `getCards`, `getCard`, `getSets`, `getReleases`, `searchCatalog`
    /// - `getCardPricing`, `getCardMarketplace`, `getCardPopulation`, `getReleaseCalendar`
    /// - `getCollections`, `createCollection`, `updateCollection`
    /// - `getGradingCompanies`, `getGradingTypes`, `getGrades`
    /// - And many more...
    public var raw: Client {
        client
    }
}

// MARK: - Middleware

/// Middleware to add authentication headers
private struct AuthenticationMiddleware: ClientMiddleware {
    let apiKey: String

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var modifiedRequest = request
        modifiedRequest.headerFields[HTTPField.Name("X-API-Key")!] = apiKey
        return try await next(modifiedRequest, body, baseURL)
    }
}

/// Middleware to handle request timeouts
private struct TimeoutMiddleware: ClientMiddleware {
    let timeout: TimeInterval

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        // Note: Timeout handling would need to be implemented with URLSession configuration
        // This is a simplified version
        return try await next(request, body, baseURL)
    }
}

// MARK: - Image Upload Helpers

/// Builds the multipart/form-data body shared by every image-upload endpoint.
///
/// The API requires a multipart form with an `image` field that carries both a
/// `Content-Disposition` and a `Content-Type` header, so we construct the part
/// from raw headers rather than a typed `MultipartPart`.
private func imageMultipartBody(_ imageData: Data) -> MultipartBody<Components.Schemas.FileUploadInput> {
    var headerFields = HTTPFields()
    headerFields[.contentDisposition] = #"form-data; name="image"; filename="image.jpg""#
    headerFields[.contentType] = "image/jpeg"

    let rawPart = MultipartRawPart(headerFields: headerFields, body: HTTPBody(imageData))
    return [.undocumented(rawPart)]
}

// MARK: - Identify API Helper

/// Card identification API endpoints for AI-powered card recognition.
///
/// The Identify API uses advanced machine learning to recognize trading cards from photos.
/// It automatically handles:
/// - HEIC to JPEG conversion (iPhone's default photo format)
/// - Image resizing and optimization
/// - Orientation correction
/// - Compression for faster uploads
///
/// # Supported Input Formats
/// - `UIImage` (iOS/tvOS/watchOS)
/// - `NSImage` (macOS)
/// - `Data` (raw image data)
/// - `URL` (file path)
///
/// # Example
/// ```swift
/// // From UIImagePickerController or PHPickerViewController
/// let image: UIImage = // ... selected from camera or library
/// let result = try await client.identify.card(image)
///
/// // Identification can be scoped to a known segment (e.g. "baseball")
/// let result = try await client.identify.cardBySegment(image, segment: "baseball")
///
/// // Access identification results
/// if case .ok(let response) = result {
///     for detection in response.body.json.detections ?? [] {
///         print("Identified: \(detection.card.name ?? "Unknown") [\(detection.confidence)]")
///     }
/// }
/// ```
public class IdentifyAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    #if canImport(UIKit)
    /// Identify a trading card from a UIImage.
    ///
    /// This method accepts images from iOS camera, photo library, or any `UIImage` source.
    /// HEIC images are automatically converted to JPEG, and the image is optimized for upload.
    ///
    /// - Parameters:
    ///   - image: The image containing the trading card
    ///   - optimized: Whether to optimize the image for upload (smallest dimension: 900px, 80% JPEG quality). Default: true
    /// - Returns: Card identification result with matched card information
    /// - Throws: ``CardSightAIError/imageProcessingError(_:)`` if image processing fails
    /// - Throws: ``CardSightAIError/networkError(_:)`` if upload fails
    /// - Throws: ``CardSightAIError/apiError(statusCode:message:response:)`` if identification fails
    ///
    /// # Example
    /// ```swift
    /// // Capture from camera with optimization (recommended for cellular networks)
    /// let result = try await client.identify.card(selectedImage)
    ///
    /// // Or disable optimization to send full resolution
    /// let result = try await client.identify.card(selectedImage, optimized: false)
    /// ```
    ///
    /// - Note: When optimized is true, images are resized so the smallest dimension is 900px with 80% JPEG quality.
    ///   When optimized is false but autoProcessImages is enabled, images are resized to maximum 2048x2048 pixels.
    ///   Configure ``ImageProcessingOptions`` in ``CardSightAIConfig`` to customize non-optimized processing.
    public func card(_ image: UIImage, optimized: Bool = true) async throws -> Operations.identifyCard.Output {
        try await identify(prepare(image, optimized: optimized))
    }

    /// Identify a trading card from a UIImage, scoped to a known segment (e.g. `"baseball"`).
    ///
    /// Scoping to a segment can improve accuracy and speed when the sport/TCG type is already known.
    ///
    /// - Parameters:
    ///   - image: The image containing the trading card
    ///   - segment: The segment slug or UUID to scope identification to (e.g. `"baseball"`, `"football"`)
    ///   - optimized: Whether to optimize the image for upload. Default: true
    /// - Returns: Card identification result with matched card information
    public func cardBySegment(_ image: UIImage, segment: String, optimized: Bool = true) async throws -> Operations.identifyCardBySegment.Output {
        try await identify(prepare(image, optimized: optimized), segment: segment)
    }

    private func prepare(_ image: UIImage, optimized: Bool) async throws -> Data {
        let client = try requireClient()
        return try await client.imageProcessor.prepareForUpload(image, optimized: optimized, autoProcess: client.config.autoProcessImages)
    }
    #endif

    #if canImport(AppKit)
    /// Identify a card from an NSImage.
    ///
    /// - Parameters:
    ///   - image: The image containing the trading card
    ///   - optimized: Whether to optimize the image for upload (smallest dimension: 900px, 80% JPEG quality). Default: true
    /// - Returns: Card identification result with matched card information
    public func card(_ image: NSImage, optimized: Bool = true) async throws -> Operations.identifyCard.Output {
        try await identify(prepare(image, optimized: optimized))
    }

    /// Identify a card from an NSImage, scoped to a known segment (e.g. `"baseball"`).
    ///
    /// - Parameters:
    ///   - image: The image containing the trading card
    ///   - segment: The segment slug or UUID to scope identification to
    ///   - optimized: Whether to optimize the image for upload. Default: true
    /// - Returns: Card identification result with matched card information
    public func cardBySegment(_ image: NSImage, segment: String, optimized: Bool = true) async throws -> Operations.identifyCardBySegment.Output {
        try await identify(prepare(image, optimized: optimized), segment: segment)
    }

    private func prepare(_ image: NSImage, optimized: Bool) async throws -> Data {
        let client = try requireClient()
        return try await client.imageProcessor.prepareForUpload(image, optimized: optimized, autoProcess: client.config.autoProcessImages)
    }
    #endif

    /// Identify a card from raw image data.
    ///
    /// - Parameters:
    ///   - imageData: The image data to process (JPEG, PNG, or HEIC/HEIF)
    ///   - optimized: Whether to optimize the image for upload. Default: true
    /// - Returns: Card identification result with matched card information
    public func card(_ imageData: Data, optimized: Bool = true) async throws -> Operations.identifyCard.Output {
        try await identify(prepare(imageData, optimized: optimized))
    }

    /// Identify a card from raw image data, scoped to a known segment.
    public func cardBySegment(_ imageData: Data, segment: String, optimized: Bool = true) async throws -> Operations.identifyCardBySegment.Output {
        try await identify(prepare(imageData, optimized: optimized), segment: segment)
    }

    /// Identify a card from a file URL.
    ///
    /// - Parameters:
    ///   - url: The URL of the image file
    ///   - optimized: Whether to optimize the image for upload. Default: true
    /// - Returns: Card identification result with matched card information
    public func card(_ url: URL, optimized: Bool = true) async throws -> Operations.identifyCard.Output {
        try await identify(prepare(url, optimized: optimized))
    }

    /// Identify a card from a file URL, scoped to a known segment.
    public func cardBySegment(_ url: URL, segment: String, optimized: Bool = true) async throws -> Operations.identifyCardBySegment.Output {
        try await identify(prepare(url, optimized: optimized), segment: segment)
    }

    private func prepare(_ imageData: Data, optimized: Bool) async throws -> Data {
        let client = try requireClient()
        return try await client.imageProcessor.prepareForUpload(imageData, optimized: optimized, autoProcess: client.config.autoProcessImages)
    }

    private func prepare(_ url: URL, optimized: Bool) async throws -> Data {
        let client = try requireClient()
        return try await client.imageProcessor.prepareForUpload(url, optimized: optimized, autoProcess: client.config.autoProcessImages)
    }

    private func identify(_ imageData: Data) async throws -> Operations.identifyCard.Output {
        let client = try requireClient()
        let input = Operations.identifyCard.Input(body: .multipartForm(imageMultipartBody(imageData)))
        return try await client.raw.identifyCard(input)
    }

    private func identify(_ imageData: Data, segment: String) async throws -> Operations.identifyCardBySegment.Output {
        let client = try requireClient()
        let input = Operations.identifyCardBySegment.Input(
            path: .init(segment: segment),
            body: .multipartForm(imageMultipartBody(imageData))
        )
        return try await client.raw.identifyCardBySegment(input)
    }

    private func requireClient() throws -> CardSightAI {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return client
    }
}

// MARK: - Detect API Helper

/// Lightweight card-presence detection.
///
/// `detect.card` is a faster, cheaper alternative to full identification when you
/// only need to know whether a trading card is present in an image (and how many),
/// without resolving it against the catalog. It shares the same automatic image
/// processing as ``IdentifyAPI``.
///
/// # Example
/// ```swift
/// let result = try await client.detect.card(image)
/// if case .ok(let response) = result {
///     print("Detected \(response.body.json.count) card(s)")
/// }
/// ```
public class DetectAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    #if canImport(UIKit)
    /// Detect whether a trading card is present in a UIImage.
    /// - Parameters:
    ///   - image: The image to inspect
    ///   - optimized: Whether to optimize the image for upload. Default: true
    /// - Returns: Detection result with `detected` flag and card `count`
    public func card(_ image: UIImage, optimized: Bool = true) async throws -> Operations.detectCard.Output {
        let client = try requireClient()
        let data = try await client.imageProcessor.prepareForUpload(image, optimized: optimized, autoProcess: client.config.autoProcessImages)
        return try await detect(data)
    }
    #endif

    #if canImport(AppKit)
    /// Detect whether a trading card is present in an NSImage.
    public func card(_ image: NSImage, optimized: Bool = true) async throws -> Operations.detectCard.Output {
        let client = try requireClient()
        let data = try await client.imageProcessor.prepareForUpload(image, optimized: optimized, autoProcess: client.config.autoProcessImages)
        return try await detect(data)
    }
    #endif

    /// Detect whether a trading card is present in raw image data.
    public func card(_ imageData: Data, optimized: Bool = true) async throws -> Operations.detectCard.Output {
        let client = try requireClient()
        let data = try await client.imageProcessor.prepareForUpload(imageData, optimized: optimized, autoProcess: client.config.autoProcessImages)
        return try await detect(data)
    }

    /// Detect whether a trading card is present in an image at a file URL.
    public func card(_ url: URL, optimized: Bool = true) async throws -> Operations.detectCard.Output {
        let client = try requireClient()
        let data = try await client.imageProcessor.prepareForUpload(url, optimized: optimized, autoProcess: client.config.autoProcessImages)
        return try await detect(data)
    }

    private func detect(_ imageData: Data) async throws -> Operations.detectCard.Output {
        let client = try requireClient()
        let input = Operations.detectCard.Input(body: .multipartForm(imageMultipartBody(imageData)))
        return try await client.raw.detectCard(input)
    }

    private func requireClient() throws -> CardSightAI {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return client
    }
}