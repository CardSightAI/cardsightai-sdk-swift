import Foundation

/// Collectors API endpoints for managing collector profiles
public class CollectorsAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    /// List all collectors
    /// - Parameter query: Query parameters for filtering and pagination
    /// - Returns: Paginated list of collectors
    public func list(
        query: Operations.get_sol_v1_sol_collectors_sol_.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_collectors_sol_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_collectors_sol_(.init(query: query))
    }

    /// Create a new collector
    /// - Parameter body: Collector creation data
    /// - Returns: Created collector
    public func create(
        body: Operations.post_sol_v1_sol_collectors_sol_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_collectors_sol_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.post_sol_v1_sol_collectors_sol_(.init(body: body))
    }

    /// Get collector details
    /// - Parameter collectorId: Collector ID
    /// - Returns: Collector details
    public func get(
        collectorId: String
    ) async throws -> Operations.get_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_.Input.Path(collectorId: collectorId)
        return try await client.raw.get_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_(.init(path: path))
    }

    /// Update collector
    /// - Parameters:
    ///   - collectorId: Collector ID
    ///   - body: Updated collector data
    /// - Returns: Updated collector
    public func update(
        collectorId: String,
        body: Operations.put_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_.Input.Body
    ) async throws -> Operations.put_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.put_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_.Input.Path(collectorId: collectorId)
        return try await client.raw.put_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_(.init(path: path, body: body))
    }

    /// Delete collector
    /// - Parameter collectorId: Collector ID
    /// - Returns: Deletion result
    public func delete(
        collectorId: String
    ) async throws -> Operations.delete_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.delete_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_.Input.Path(collectorId: collectorId)
        return try await client.raw.delete_sol_v1_sol_collectors_sol__lcub_collectorId_rcub_(.init(path: path))
    }
}
