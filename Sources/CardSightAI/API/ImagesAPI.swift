import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

/// Images API endpoints for retrieving card images
public class ImagesAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    #if canImport(UIKit)
    /// Get card image as UIImage (iOS/tvOS/watchOS)
    /// - Parameters:
    ///   - id: Card ID
    ///   - format: Image format ('raw' for binary JPEG, 'json' for base64)
    /// - Returns: UIImage of the card
    public func getCardImage(id: String, format: String = "raw") async throws -> UIKit.UIImage {
        let imageData = try await getCardData(id: id, format: format)
        guard let image = UIKit.UIImage(data: imageData) else {
            throw CardSightAIError.imageProcessingError("Failed to create UIImage from response data")
        }
        return image
    }
    #endif

    #if canImport(AppKit)
    /// Get card image as NSImage (macOS)
    /// - Parameters:
    ///   - id: Card ID
    ///   - format: Image format ('raw' for binary JPEG, 'json' for base64)
    /// - Returns: NSImage of the card
    public func getCardImage(id: String, format: String = "raw") async throws -> AppKit.NSImage {
        let imageData = try await getCardData(id: id, format: format)
        guard let image = AppKit.NSImage(data: imageData) else {
            throw CardSightAIError.imageProcessingError("Failed to create NSImage from response data")
        }
        return image
    }
    #endif

    /// Get card image as raw Data
    /// - Parameters:
    ///   - id: Card ID
    ///   - format: Image format ('raw' for binary JPEG, 'json' for base64)
    /// - Returns: Image data
    public func getCardData(id: String, format: String = "raw") async throws -> Data {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Manual URLSession implementation required because the OpenAPI spec
        // doesn't include the response body schema for the images endpoint.
        // The generated client discards the response body.

        guard let url = URL(string: "\(client.config.baseURL)/v1/images/cards/\(id)?format=\(format)") else {
            throw CardSightAIError.invalidInput("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(client.config.apiKey, forHTTPHeaderField: "X-API-Key")
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

        // For 'json' format, extract base64 image data
        if format == "json" {
            do {
                let decoder = JSONDecoder()
                let jsonResponse = try decoder.decode(ImageJSONResponse.self, from: data)
                guard let imageData = Data(base64Encoded: jsonResponse.image) else {
                    throw CardSightAIError.imageProcessingError("Failed to decode base64 image data")
                }
                return imageData
            } catch {
                throw CardSightAIError.decodingError(error)
            }
        }

        // For 'raw' format, return data directly
        return data
    }

    /// JSON response structure for format=json
    private struct ImageJSONResponse: Codable {
        let image: String  // base64-encoded image
        let mimeType: String?
    }
}
