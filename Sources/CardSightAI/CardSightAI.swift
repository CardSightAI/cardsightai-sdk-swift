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

    /// Health check endpoints
    ///
    /// Provides methods to check API connectivity and authentication status.
    /// - ``HealthAPI/check()`` - Basic health check (no authentication)
    /// - ``HealthAPI/checkAuth()`` - Authenticated health check
    public lazy var health = HealthAPI(client: self)

    /// Card identification endpoints
    ///
    /// Identify trading cards from images using AI-powered recognition.
    /// Automatically handles HEIC conversion, resizing, and optimization.
    ///
    /// # Example
    /// ```swift
    /// let image: UIImage = // ... from camera or photo library
    /// let result = try await client.identify.card(image)
    /// ```
    public lazy var identify = IdentifyAPI(client: self)

    /// Catalog endpoints
    ///
    /// Search and browse the comprehensive baseball card catalog with 2M+ cards.
    /// Includes cards, sets, releases, manufacturers, and more.
    public lazy var catalog = CatalogAPI(client: self)

    /// Collection management endpoints
    ///
    /// Manage personal card collections with full CRUD operations and analytics.
    public lazy var collections = CollectionsAPI(client: self)

    /// Collector management endpoints
    ///
    /// Manage collector profiles and user information.
    public lazy var collectors = CollectorsAPI(client: self)

    /// Lists management endpoints
    ///
    /// Create and manage wishlists of wanted cards.
    public lazy var lists = ListsAPI(client: self)

    /// Grading endpoints
    ///
    /// Access grading information for PSA, BGS, and SGC graded cards.
    public lazy var grades = GradesAPI(client: self)

    /// Autocomplete endpoints
    ///
    /// Get search suggestions for players, teams, sets, and more.
    public lazy var autocomplete = AutocompleteAPI(client: self)

    /// AI query endpoints
    ///
    /// Perform natural language queries powered by AI.
    public lazy var ai = AIAPI(client: self)

    /// Image retrieval endpoints
    ///
    /// Retrieve card images as platform-native types (UIImage/NSImage).
    public lazy var images = ImagesAPI(client: self)

    /// Feedback endpoints
    ///
    /// Submit feedback on card identifications and search results.
    public lazy var feedback = FeedbackAPI(client: self)

    /// Subscription endpoints
    ///
    /// Manage subscription status and billing information.
    public lazy var subscription = SubscriptionAPI(client: self)

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

    /// Get the underlying OpenAPI client for advanced use cases
    public var raw: Client {
        return client
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

// MARK: - API Endpoint Groups

/// Health check API endpoints for testing connectivity and authentication.
///
/// Use these endpoints to validate your API configuration and connectivity
/// before making actual API calls.
public class HealthAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    /// Perform a basic health check without authentication.
    ///
    /// This endpoint checks basic API connectivity without requiring a valid API key.
    /// Useful for verifying that the API is reachable from your environment.
    ///
    /// - Returns: Health check response containing API status
    /// - Throws: ``CardSightAIError/networkError(_:)`` if unable to reach the API
    /// - Throws: ``CardSightAIError/apiError(statusCode:message:response:)`` if the API returns an error
    ///
    /// # Example
    /// ```swift
    /// let health = try await client.health.check()
    /// print("API status: \(health.status)")
    /// ```
    ///
    /// - Note: This endpoint does not validate your API key
    public func check() async throws -> Operations.get_sol_health.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_health()
    }

    /// Perform an authenticated health check.
    ///
    /// This endpoint validates both API connectivity and your API key.
    /// Use this to verify your API key is valid and has proper permissions.
    ///
    /// - Returns: Health check response with authentication confirmation
    /// - Throws: ``CardSightAIError/authenticationError(_:)`` if API key is invalid
    /// - Throws: ``CardSightAIError/networkError(_:)`` if unable to reach the API
    /// - Throws: ``CardSightAIError/apiError(statusCode:message:response:)`` if the API returns an error
    ///
    /// # Example
    /// ```swift
    /// do {
    ///     let health = try await client.health.checkAuth()
    ///     print("✅ API key is valid")
    /// } catch let error as CardSightAIError {
    ///     if error.isAuthenticationError {
    ///         print("❌ Invalid API key")
    ///     }
    /// }
    /// ```
    public func checkAuth() async throws -> Operations.get_sol_health_sol_auth.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_health_sol_auth()
    }
}

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
    public func card(_ image: UIImage, optimized: Bool = true) async throws -> Operations.post_sol_v1_sol_identify_sol_card.Output {
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
    public func card(_ image: NSImage, optimized: Bool = true) async throws -> Operations.post_sol_v1_sol_identify_sol_card.Output {
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
    public func card(_ imageData: Data, optimized: Bool = true) async throws -> Operations.post_sol_v1_sol_identify_sol_card.Output {
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
    public func card(_ url: URL, optimized: Bool = true) async throws -> Operations.post_sol_v1_sol_identify_sol_card.Output {
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

    private func cardFromData(_ imageData: Data) async throws -> Operations.post_sol_v1_sol_identify_sol_card.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Manual multipart form-data implementation required because the OpenAPI spec
        // doesn't include the request body schema for the identify endpoint.
        // We bypass the generated client and use URLSession directly.

        // Build multipart form-data body
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        // Add form field for image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"card.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Create custom request using URLSession directly
        guard let url = URL(string: "\(client.config.baseURL)/v1/identify/card") else {
            throw CardSightAIError.invalidInput("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(client.config.apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = client.config.timeout

        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CardSightAIError.networkError(NSError(domain: "CardSightAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]))
        }

        // Handle HTTP errors
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw CardSightAIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage, response: data)
        }

        // Decode response
        let decoder = JSONDecoder()
        do {
            let identifyResponse = try decoder.decode(Operations.post_sol_v1_sol_identify_sol_card.Output.Ok.Body.jsonPayload.self, from: data)
            return .ok(.init(body: .json(identifyResponse)))
        } catch {
            throw CardSightAIError.decodingError(error)
        }
    }
}

// All API implementations are in API/ directory
// CatalogAPI: API/CatalogAPI.swift
// CollectionsAPI: API/CollectionsAPI.swift
// All remaining APIs: API/RemainingAPIs.swift