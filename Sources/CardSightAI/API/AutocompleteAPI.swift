import Foundation

/// Autocomplete API endpoints for search suggestions
public class AutocompleteAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    /// Autocomplete cards by name
    /// - Parameter query: Query parameters (q field for search term)
    /// - Returns: Card autocomplete suggestions
    public func cards(
        query: Operations.get_sol_v1_sol_autocomplete_sol_cards.Input.Query
    ) async throws -> Operations.get_sol_v1_sol_autocomplete_sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_autocomplete_sol_cards(.init(query: query))
    }

    /// Autocomplete sets by name
    /// - Parameter query: Query parameters (q field for search term)
    /// - Returns: Set autocomplete suggestions
    public func sets(
        query: Operations.get_sol_v1_sol_autocomplete_sol_sets.Input.Query
    ) async throws -> Operations.get_sol_v1_sol_autocomplete_sol_sets.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_autocomplete_sol_sets(.init(query: query))
    }

    /// Autocomplete releases by name
    /// - Parameter query: Query parameters (q field for search term)
    /// - Returns: Release autocomplete suggestions
    public func releases(
        query: Operations.get_sol_v1_sol_autocomplete_sol_releases.Input.Query
    ) async throws -> Operations.get_sol_v1_sol_autocomplete_sol_releases.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_autocomplete_sol_releases(.init(query: query))
    }

    /// Autocomplete manufacturers by name
    /// - Parameter query: Query parameters (q field for search term)
    /// - Returns: Manufacturer autocomplete suggestions
    public func manufacturers(
        query: Operations.get_sol_v1_sol_autocomplete_sol_manufacturers.Input.Query
    ) async throws -> Operations.get_sol_v1_sol_autocomplete_sol_manufacturers.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_autocomplete_sol_manufacturers(.init(query: query))
    }

    /// Autocomplete segments by name
    /// - Parameter query: Query parameters (q field for search term)
    /// - Returns: Segment autocomplete suggestions
    public func segments(
        query: Operations.get_sol_v1_sol_autocomplete_sol_segments.Input.Query
    ) async throws -> Operations.get_sol_v1_sol_autocomplete_sol_segments.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_autocomplete_sol_segments(.init(query: query))
    }

    /// Autocomplete years
    /// - Parameter query: Query parameters (q field for search term)
    /// - Returns: Year autocomplete suggestions
    public func years(
        query: Operations.get_sol_v1_sol_autocomplete_sol_years.Input.Query
    ) async throws -> Operations.get_sol_v1_sol_autocomplete_sol_years.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_autocomplete_sol_years(.init(query: query))
    }
}
