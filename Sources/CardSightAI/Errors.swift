import Foundation

/// Errors that can be thrown by the CardSightAI SDK
public enum CardSightAIError: LocalizedError {
    /// Authentication error - missing or invalid API key
    case authenticationError(String)

    /// Network error
    case networkError(Error)

    /// API error with HTTP status code and message
    case apiError(statusCode: Int, message: String, response: Data?)

    /// Image processing error
    case imageProcessingError(String)

    /// Invalid input provided
    case invalidInput(String)

    /// Decoding error when parsing API responses
    case decodingError(Error)

    /// Request timeout
    case timeout

    /// Unknown error
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .apiError(let statusCode, let message, _):
            return "API Error (\(statusCode)): \(message)"
        case .imageProcessingError(let message):
            return "Image Processing Error: \(message)"
        case .invalidInput(let message):
            return "Invalid Input: \(message)"
        case .decodingError(let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .timeout:
            return "Request Timeout"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }

    public var failureReason: String? {
        switch self {
        case .authenticationError(let message):
            return message
        case .networkError(let error):
            return error.localizedDescription
        case .apiError(_, let message, _):
            return message
        case .imageProcessingError(let message):
            return message
        case .invalidInput(let message):
            return message
        case .decodingError(let error):
            return error.localizedDescription
        case .timeout:
            return "The request took too long to complete"
        case .unknown(let message):
            return message
        }
    }

    /// HTTP status code if this is an API error
    public var statusCode: Int? {
        switch self {
        case .apiError(let statusCode, _, _):
            return statusCode
        default:
            return nil
        }
    }

    /// Response data if available (for API errors)
    public var responseData: Data? {
        switch self {
        case .apiError(_, _, let data):
            return data
        default:
            return nil
        }
    }

    /// Check if this is an authentication error
    public var isAuthenticationError: Bool {
        switch self {
        case .authenticationError:
            return true
        case .apiError(let statusCode, _, _):
            return statusCode == 401 || statusCode == 403
        default:
            return false
        }
    }

    /// Check if this is a network error
    public var isNetworkError: Bool {
        switch self {
        case .networkError, .timeout:
            return true
        default:
            return false
        }
    }

    /// Check if this error is retryable
    public var isRetryable: Bool {
        switch self {
        case .networkError, .timeout:
            return true
        case .apiError(let statusCode, _, _):
            // Retry on 5xx errors and rate limiting
            return statusCode >= 500 || statusCode == 429
        default:
            return false
        }
    }
}