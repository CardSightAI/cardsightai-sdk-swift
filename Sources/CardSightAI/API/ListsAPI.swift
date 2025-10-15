import Foundation

/// Lists API endpoints for managing want lists and wishlists
public class ListsAPI {
    private weak var client: CardSightAI?

    /// Cards within lists API
    public lazy var cards = ListCardsAPI(client: client)

    init(client: CardSightAI) {
        self.client = client
    }

    /// List all lists
    /// - Parameter query: Query parameters for filtering and pagination
    /// - Returns: Paginated list of lists
    public func list(
        query: Operations.get_sol_v1_sol_lists_sol_.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_lists_sol_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_lists_sol_(.init(query: query))
    }

    /// Create a new list
    /// - Parameter body: List creation data
    /// - Returns: Created list
    public func create(
        body: Operations.post_sol_v1_sol_lists_sol_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_lists_sol_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.post_sol_v1_sol_lists_sol_(.init(body: body))
    }

    /// Get list details
    /// - Parameter listId: List ID
    /// - Returns: List details
    public func get(
        listId: String
    ) async throws -> Operations.get_sol_v1_sol_lists_sol__lcub_listId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_lists_sol__lcub_listId_rcub_.Input.Path(listId: listId)
        return try await client.raw.get_sol_v1_sol_lists_sol__lcub_listId_rcub_(.init(path: path))
    }

    /// Update list
    /// - Parameters:
    ///   - listId: List ID
    ///   - body: Updated list data
    /// - Returns: Updated list
    public func update(
        listId: String,
        body: Operations.put_sol_v1_sol_lists_sol__lcub_listId_rcub_.Input.Body
    ) async throws -> Operations.put_sol_v1_sol_lists_sol__lcub_listId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.put_sol_v1_sol_lists_sol__lcub_listId_rcub_.Input.Path(listId: listId)
        return try await client.raw.put_sol_v1_sol_lists_sol__lcub_listId_rcub_(.init(path: path, body: body))
    }

    /// Delete list
    /// - Parameter listId: List ID
    /// - Returns: Deletion result
    public func delete(
        listId: String
    ) async throws -> Operations.delete_sol_v1_sol_lists_sol__lcub_listId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.delete_sol_v1_sol_lists_sol__lcub_listId_rcub_.Input.Path(listId: listId)
        return try await client.raw.delete_sol_v1_sol_lists_sol__lcub_listId_rcub_(.init(path: path))
    }
}

/// List cards API endpoints
public class ListCardsAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI?) {
        self.client = client
    }

    /// Get cards in a list
    /// - Parameters:
    ///   - listId: List ID
    ///   - query: Query parameters for filtering and pagination
    /// - Returns: Paginated list of cards
    public func list(
        listId: String,
        query: Operations.get_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards.Input.Path(listId: listId)
        return try await client.raw.get_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards(.init(path: path, query: query))
    }

    /// Add card(s) to a list
    /// - Parameters:
    ///   - listId: List ID
    ///   - body: Card data to add
    /// - Returns: Added card(s)
    public func add(
        listId: String,
        body: Operations.post_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards.Input.Path(listId: listId)
        return try await client.raw.post_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards(.init(path: path, body: body))
    }

    /// Remove a card from a list
    /// - Parameters:
    ///   - listId: List ID
    ///   - cardId: Card ID
    /// - Returns: Deletion result
    public func delete(
        listId: String,
        cardId: String
    ) async throws -> Operations.delete_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards_sol__lcub_cardId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.delete_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards_sol__lcub_cardId_rcub_.Input.Path(
            listId: listId,
            cardId: cardId
        )
        return try await client.raw.delete_sol_v1_sol_lists_sol__lcub_listId_rcub__sol_cards_sol__lcub_cardId_rcub_(.init(path: path))
    }
}
