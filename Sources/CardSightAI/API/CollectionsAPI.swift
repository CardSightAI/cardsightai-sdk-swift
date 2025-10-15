import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

/// Collections API endpoints for managing card collections
public class CollectionsAPI {
    private weak var client: CardSightAI?

    /// Cards within collections API
    public lazy var cards = CollectionCardsAPI(client: client)

    /// Binders within collections API
    public lazy var binders = CollectionBindersAPI(client: client)

    init(client: CardSightAI) {
        self.client = client
    }

    /// List all collections
    /// - Parameter query: Query parameters for filtering and pagination
    /// - Returns: Paginated list of collections
    public func list(
        query: Operations.get_sol_v1_sol_collection_sol_.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_collection_sol_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_collection_sol_(.init(query: query))
    }

    /// Create a new collection
    /// - Parameter body: Collection creation data
    /// - Returns: Created collection
    public func create(
        body: Operations.post_sol_v1_sol_collection_sol_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_collection_sol_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.post_sol_v1_sol_collection_sol_(.init(body: body))
    }

    /// Get collection details
    /// - Parameter collectionId: Collection ID
    /// - Returns: Collection details
    public func get(
        collectionId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub_.Input.Path(collectionId: collectionId)
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub_(.init(path: path))
    }

    /// Update collection
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - body: Updated collection data
    /// - Returns: Updated collection
    public func update(
        collectionId: String,
        body: Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub_.Input.Body
    ) async throws -> Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub_.Input.Path(collectionId: collectionId)
        return try await client.raw.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub_(.init(path: path, body: body))
    }

    /// Delete collection
    /// - Parameter collectionId: Collection ID
    /// - Returns: Deletion result
    public func delete(
        collectionId: String
    ) async throws -> Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub_.Input.Path(collectionId: collectionId)
        return try await client.raw.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub_(.init(path: path))
    }

    /// Get collection analytics
    /// - Parameter collectionId: Collection ID
    /// - Returns: Collection analytics including value, counts, etc.
    public func analytics(
        collectionId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_analytics.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_analytics.Input.Path(collectionId: collectionId)
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_analytics(.init(path: path))
    }

    /// Get collection breakdown
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - query: Query parameters for breakdown (groupBy field required)
    /// - Returns: Collection breakdown by specified grouping
    public func breakdown(
        collectionId: String,
        query: Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_breakdown.Input.Query
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_breakdown.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_breakdown.Input.Path(collectionId: collectionId)
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_breakdown(.init(path: path, query: query))
    }

    /// Get set progress for all sets in collection
    /// - Parameter collectionId: Collection ID
    /// - Returns: Progress for all sets
    public func setProgress(
        collectionId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress.Input.Path(collectionId: collectionId)
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress(.init(path: path))
    }

    /// Get set progress for a specific set
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - setId: Set ID
    /// - Returns: Progress for the specified set
    public func setProgress(
        collectionId: String,
        setId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress_sol__lcub_setId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress_sol__lcub_setId_rcub_.Input.Path(
            collectionId: collectionId,
            setId: setId
        )
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress_sol__lcub_setId_rcub_(.init(path: path))
    }

    /// Get set progress for a specific parallel within a set
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - setId: Set ID
    ///   - parallelId: Parallel ID
    /// - Returns: Progress for the specified set and parallel
    public func setProgress(
        collectionId: String,
        setId: String,
        parallelId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress_sol__lcub_setId_rcub__sol__lcub_parallelId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress_sol__lcub_setId_rcub__sol__lcub_parallelId_rcub_.Input.Path(
            collectionId: collectionId,
            setId: setId,
            parallelId: parallelId
        )
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_set_hyphen_progress_sol__lcub_setId_rcub__sol__lcub_parallelId_rcub_(.init(path: path))
    }
}

// MARK: - Collection Cards API

/// Collection cards API endpoints
public class CollectionCardsAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI?) {
        self.client = client
    }

    /// List cards in a collection
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - query: Query parameters for filtering and pagination
    /// - Returns: Paginated list of cards in the collection
    public func list(
        collectionId: String,
        query: Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards.Input.Path(collectionId: collectionId)
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards(.init(path: path, query: query))
    }

    /// Add a card to collection
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - body: Card data to add
    /// - Returns: Added card
    public func add(
        collectionId: String,
        body: Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards.Input.Path(collectionId: collectionId)
        return try await client.raw.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards(.init(path: path, body: body))
    }

    /// Get a specific card in collection
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    /// - Returns: Card details
    public func get(
        collectionId: String,
        cardId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_.Input.Path(
            collectionId: collectionId,
            cardId: cardId
        )
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_(.init(path: path))
    }

    /// Update a card in collection
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    ///   - body: Updated card data
    /// - Returns: Updated card
    public func update(
        collectionId: String,
        cardId: String,
        body: Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_.Input.Body
    ) async throws -> Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_.Input.Path(
            collectionId: collectionId,
            cardId: cardId
        )
        return try await client.raw.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_(.init(path: path, body: body))
    }

    /// Remove a card from collection
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    /// - Returns: Deletion result
    public func delete(
        collectionId: String,
        cardId: String
    ) async throws -> Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_.Input.Path(
            collectionId: collectionId,
            cardId: cardId
        )
        return try await client.raw.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub_(.init(path: path))
    }

    /// Get card image
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    /// - Returns: Card image data
    public func getImage(
        collectionId: String,
        cardId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Input.Path(
            collectionId: collectionId,
            cardId: cardId
        )
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image(.init(path: path))
    }

    /// Get card thumbnail image
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    /// - Returns: Card thumbnail image data
    public func getThumbnail(
        collectionId: String,
        cardId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image_sol_thumb.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image_sol_thumb.Input.Path(
            collectionId: collectionId,
            cardId: cardId
        )
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image_sol_thumb(.init(path: path))
    }

    #if canImport(UIKit)
    /// Upload card image from UIImage
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    ///   - image: UIImage to upload
    /// - Returns: Upload result
    public func uploadImage(
        collectionId: String,
        cardId: String,
        image: UIKit.UIImage
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Process the image if auto-processing is enabled
        let imageData: Data
        if client.config.autoProcessImages {
            imageData = try await client.imageProcessor.processForUpload(image)
        } else {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                throw CardSightAIError.imageProcessingError("Failed to convert image to JPEG")
            }
            imageData = data
        }

        return try await uploadImageFromData(collectionId: collectionId, cardId: cardId, imageData: imageData)
    }
    #endif

    #if canImport(AppKit)
    /// Upload card image from NSImage
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    ///   - image: NSImage to upload
    /// - Returns: Upload result
    public func uploadImage(
        collectionId: String,
        cardId: String,
        image: AppKit.NSImage
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Process the image if auto-processing is enabled
        let imageData: Data
        if client.config.autoProcessImages {
            imageData = try await client.imageProcessor.processForUpload(image)
        } else {
            guard let tiffData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let data = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
                throw CardSightAIError.imageProcessingError("Failed to convert image to JPEG")
            }
            imageData = data
        }

        return try await uploadImageFromData(collectionId: collectionId, cardId: cardId, imageData: imageData)
    }
    #endif

    /// Upload card image from Data
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    ///   - imageData: Image data to upload
    /// - Returns: Upload result
    public func uploadImage(
        collectionId: String,
        cardId: String,
        imageData: Data
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Process the image if auto-processing is enabled
        let processedData: Data
        if client.config.autoProcessImages {
            processedData = try await client.imageProcessor.processForUpload(imageData)
        } else {
            processedData = imageData
        }

        return try await uploadImageFromData(collectionId: collectionId, cardId: cardId, imageData: processedData)
    }

    /// Upload card image from URL
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - cardId: Card ID
    ///   - url: File URL containing image
    /// - Returns: Upload result
    public func uploadImage(
        collectionId: String,
        cardId: String,
        url: URL
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Process the image if auto-processing is enabled
        let imageData: Data
        if client.config.autoProcessImages {
            imageData = try await client.imageProcessor.processForUpload(url)
        } else {
            imageData = try Data(contentsOf: url)
        }

        return try await uploadImageFromData(collectionId: collectionId, cardId: cardId, imageData: imageData)
    }

    private func uploadImageFromData(
        collectionId: String,
        cardId: String,
        imageData: Data
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        // Manual multipart form-data implementation required because the OpenAPI spec
        // doesn't include the request body schema for the image upload endpoint.
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
        guard let url = URL(string: "\(client.config.baseURL)/v1/collection/\(collectionId)/cards/\(cardId)/image") else {
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
            let uploadResponse = try decoder.decode(Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_cards_sol__lcub_cardId_rcub__sol_image.Output.Ok.Body.jsonPayload.self, from: data)
            return .ok(.init(body: .json(uploadResponse)))
        } catch {
            throw CardSightAIError.decodingError(error)
        }
    }
}

// MARK: - Collection Binders API

/// Collection binders API endpoints
public class CollectionBindersAPI {
    private weak var client: CardSightAI?

    /// Cards within binders API
    public lazy var cards = BinderCardsAPI(client: client)

    init(client: CardSightAI?) {
        self.client = client
    }

    /// List binders in a collection
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - query: Query parameters for filtering and pagination
    /// - Returns: Paginated list of binders
    public func list(
        collectionId: String,
        query: Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders.Input.Path(collectionId: collectionId)
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders(.init(path: path, query: query))
    }

    /// Create a new binder
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - body: Binder creation data
    /// - Returns: Created binder
    public func create(
        collectionId: String,
        body: Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders.Input.Path(collectionId: collectionId)
        return try await client.raw.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders(.init(path: path, body: body))
    }

    /// Get binder details
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - binderId: Binder ID
    /// - Returns: Binder details
    public func get(
        collectionId: String,
        binderId: String
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_.Input.Path(
            collectionId: collectionId,
            binderId: binderId
        )
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_(.init(path: path))
    }

    /// Update a binder
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - binderId: Binder ID
    ///   - body: Updated binder data
    /// - Returns: Updated binder
    public func update(
        collectionId: String,
        binderId: String,
        body: Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_.Input.Body
    ) async throws -> Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_.Input.Path(
            collectionId: collectionId,
            binderId: binderId
        )
        return try await client.raw.put_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_(.init(path: path, body: body))
    }

    /// Delete a binder
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - binderId: Binder ID
    /// - Returns: Deletion result
    public func delete(
        collectionId: String,
        binderId: String
    ) async throws -> Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_.Input.Path(
            collectionId: collectionId,
            binderId: binderId
        )
        return try await client.raw.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub_(.init(path: path))
    }
}

// MARK: - Binder Cards API

/// Binder cards API endpoints
public class BinderCardsAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI?) {
        self.client = client
    }

    /// List cards in a binder
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - binderId: Binder ID
    ///   - query: Query parameters for filtering and pagination
    /// - Returns: Paginated list of cards in the binder
    public func list(
        collectionId: String,
        binderId: String,
        query: Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards.Input.Path(
            collectionId: collectionId,
            binderId: binderId
        )
        return try await client.raw.get_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards(.init(path: path, query: query))
    }

    /// Add a card to binder
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - binderId: Binder ID
    ///   - body: Card data to add
    /// - Returns: Added card
    public func add(
        collectionId: String,
        binderId: String,
        body: Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards.Input.Path(
            collectionId: collectionId,
            binderId: binderId
        )
        return try await client.raw.post_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards(.init(path: path, body: body))
    }

    /// Remove a card from binder
    /// - Parameters:
    ///   - collectionId: Collection ID
    ///   - binderId: Binder ID
    ///   - cardId: Card ID
    /// - Returns: Deletion result
    public func delete(
        collectionId: String,
        binderId: String,
        cardId: String
    ) async throws -> Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards_sol__lcub_cardId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards_sol__lcub_cardId_rcub_.Input.Path(
            collectionId: collectionId,
            binderId: binderId,
            cardId: cardId
        )
        return try await client.raw.delete_sol_v1_sol_collection_sol__lcub_collectionId_rcub__sol_binders_sol__lcub_binderId_rcub__sol_cards_sol__lcub_cardId_rcub_(.init(path: path))
    }
}