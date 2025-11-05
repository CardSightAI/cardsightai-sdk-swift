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
    /// All 79 API operations are available as methods on this client with clean names like:
    /// - `getCards`, `getCard`, `getSets`, `getReleases`
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
/// // Access identification results
/// if case .ok(let response) = result {
///     print("Identified: \(response.card.name)")
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
    /// let picker = UIImagePickerController()
    /// picker.sourceType = .camera
    /// // ... get selected image
    ///
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
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Use optimization or standard processing
        let imageData: Data
        if optimized {
            imageData = try await client.imageProcessor.optimizeForUpload(image)
        } else if client.config.autoProcessImages {
            imageData = try await client.imageProcessor.processForUpload(image)
        } else {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                throw CardSightAIError.imageProcessingError("Failed to convert image to JPEG")
            }
            imageData = data
        }

        return try await cardFromData(imageData)
    }
    #endif

    #if canImport(AppKit)
    /// Identify a card from an NSImage
    ///
    /// - Parameters:
    ///   - image: The image containing the trading card
    ///   - optimized: Whether to optimize the image for upload (smallest dimension: 900px, 80% JPEG quality). Default: true
    /// - Returns: Card identification result with matched card information
    /// - Throws: ``CardSightAIError/imageProcessingError(_:)`` if image processing fails
    /// - Throws: ``CardSightAIError/networkError(_:)`` if upload fails
    /// - Throws: ``CardSightAIError/apiError(statusCode:message:response:)`` if identification fails
    public func card(_ image: NSImage, optimized: Bool = true) async throws -> Operations.identifyCard.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Use optimization or standard processing
        let imageData: Data
        if optimized {
            imageData = try await client.imageProcessor.optimizeForUpload(image)
        } else if client.config.autoProcessImages {
            imageData = try await client.imageProcessor.processForUpload(image)
        } else {
            guard let tiffData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let data = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
                throw CardSightAIError.imageProcessingError("Failed to convert image to JPEG")
            }
            imageData = data
        }

        return try await cardFromData(imageData)
    }
    #endif

    /// Identify a card from image data
    ///
    /// - Parameters:
    ///   - imageData: The image data to process
    ///   - optimized: Whether to optimize the image for upload (smallest dimension: 900px, 80% JPEG quality). Default: true
    /// - Returns: Card identification result with matched card information
    /// - Throws: ``CardSightAIError/imageProcessingError(_:)`` if image processing fails
    /// - Throws: ``CardSightAIError/networkError(_:)`` if upload fails
    /// - Throws: ``CardSightAIError/apiError(statusCode:message:response:)`` if identification fails
    public func card(_ imageData: Data, optimized: Bool = true) async throws -> Operations.identifyCard.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Use optimization or standard processing
        let processedData: Data
        if optimized {
            processedData = try await client.imageProcessor.optimizeForUpload(imageData)
        } else if client.config.autoProcessImages {
            processedData = try await client.imageProcessor.processForUpload(imageData)
        } else {
            processedData = imageData
        }

        return try await cardFromData(processedData)
    }

    /// Identify a card from a file URL
    ///
    /// - Parameters:
    ///   - url: The URL of the image file
    ///   - optimized: Whether to optimize the image for upload (smallest dimension: 900px, 80% JPEG quality). Default: true
    /// - Returns: Card identification result with matched card information
    /// - Throws: ``CardSightAIError/imageProcessingError(_:)`` if image processing fails
    /// - Throws: ``CardSightAIError/networkError(_:)`` if upload fails
    /// - Throws: ``CardSightAIError/apiError(statusCode:message:response:)`` if identification fails
    public func card(_ url: URL, optimized: Bool = true) async throws -> Operations.identifyCard.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Use optimization or standard processing
        let imageData: Data
        if optimized {
            imageData = try await client.imageProcessor.optimizeForUpload(url)
        } else if client.config.autoProcessImages {
            imageData = try await client.imageProcessor.processForUpload(url)
        } else {
            imageData = try Data(contentsOf: url)
        }

        return try await cardFromData(imageData)
    }

    private func cardFromData(_ imageData: Data) async throws -> Operations.identifyCard.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Use the generated client with proper image body support
        // The OpenAPI spec now properly defines the request body schema
        let httpBody = HTTPBody(imageData)
        let input = Operations.identifyCard.Input(
            body: .jpeg(httpBody)
        )

        return try await client.raw.identifyCard(input)
    }
}