import Foundation

/// Configuration options for the CardSightAI SDK
public struct CardSightAIConfig {
    /// API key for authentication. If not provided, will check CARDSIGHTAI_API_KEY environment variable
    public let apiKey: String

    /// Base URL for the API. Defaults to production URL
    public let baseURL: String

    /// Request timeout in seconds
    public let timeout: TimeInterval

    /// Custom headers to include with every request
    public let customHeaders: [String: String]

    /// Image processing options
    public let imageProcessing: ImageProcessingOptions

    /// Whether to automatically process images (convert HEIC to JPEG, resize, etc.)
    public let autoProcessImages: Bool

    /// Initialize a new configuration
    /// - Parameters:
    ///   - apiKey: API key for authentication. If nil, will check environment variable
    ///   - baseURL: Base URL for the API
    ///   - timeout: Request timeout in seconds
    ///   - customHeaders: Additional headers to include with requests
    ///   - imageProcessing: Image processing options
    ///   - autoProcessImages: Whether to automatically process images
    public init(
        apiKey: String? = nil,
        baseURL: String = "https://api.cardsight.ai",
        timeout: TimeInterval = 30,
        customHeaders: [String: String] = [:],
        imageProcessing: ImageProcessingOptions = ImageProcessingOptions(),
        autoProcessImages: Bool = true
    ) throws {
        // Get API key from parameter or environment
        if let providedKey = apiKey {
            self.apiKey = providedKey
        } else if let envKey = ProcessInfo.processInfo.environment["CARDSIGHTAI_API_KEY"] {
            self.apiKey = envKey
        } else {
            throw CardSightAIError.authenticationError("API key is required. Set it via init() or CARDSIGHTAI_API_KEY environment variable")
        }

        self.baseURL = baseURL
        self.timeout = timeout
        self.customHeaders = customHeaders
        self.imageProcessing = imageProcessing
        self.autoProcessImages = autoProcessImages
    }
}

/// Options for image processing
public struct ImageProcessingOptions {
    /// Maximum dimension (width or height) for resized images
    public let maxDimension: CGFloat

    /// JPEG compression quality (0.0 to 1.0)
    public let jpegQuality: CGFloat

    /// Maximum file size in megabytes
    public let maxFileSizeMB: Double

    /// Whether to correct image orientation based on EXIF data
    public let correctOrientation: Bool

    /// Initialize image processing options
    /// - Parameters:
    ///   - maxDimension: Maximum dimension for resized images (default: 2048)
    ///   - jpegQuality: JPEG compression quality (default: 0.8)
    ///   - maxFileSizeMB: Maximum file size in MB (default: 5.0)
    ///   - correctOrientation: Whether to correct orientation (default: true)
    public init(
        maxDimension: CGFloat = 2048,
        jpegQuality: CGFloat = 0.8,
        maxFileSizeMB: Double = 5.0,
        correctOrientation: Bool = true
    ) {
        self.maxDimension = maxDimension
        self.jpegQuality = min(max(jpegQuality, 0.0), 1.0) // Clamp to 0...1
        self.maxFileSizeMB = maxFileSizeMB
        self.correctOrientation = correctOrientation
    }
}