import Foundation

/// Catalog API endpoints for searching cards, sets, releases, and related data
public class CatalogAPI {
    private weak var client: CardSightAI?

    /// Cards API group
    public lazy var cards = CardsAPI(client: client)

    /// Sets API group
    public lazy var sets = SetsAPI(client: client)

    /// Releases API group
    public lazy var releases = ReleasesAPI(client: client)

    /// Attributes API group
    public lazy var attributes = AttributesAPI(client: client)

    init(client: CardSightAI) {
        self.client = client
    }

    /// Get catalog statistics
    /// - Returns: Statistics about the catalog including counts of cards, sets, releases
    public func statistics() async throws -> Operations.get_sol_v1_sol_catalog_sol_statistics.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_statistics(.init())
    }

    /// Get manufacturers list
    /// - Parameters:
    ///   - query: Query parameters for filtering and pagination
    /// - Returns: List of manufacturers
    public func manufacturers(
        query: Operations.get_sol_v1_sol_catalog_sol_manufacturers.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_manufacturers.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_manufacturers(.init(query: query))
    }

    /// Get segments list
    /// - Parameters:
    ///   - query: Query parameters for filtering and pagination
    /// - Returns: List of segments (e.g., Baseball, Pokemon, etc.)
    public func segments(
        query: Operations.get_sol_v1_sol_catalog_sol_segments.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_segments.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_segments(.init(query: query))
    }

    /// Get parallels list
    /// - Parameters:
    ///   - query: Query parameters for filtering and pagination
    /// - Returns: List of parallel types
    public func parallels(
        query: Operations.get_sol_v1_sol_catalog_sol_parallels.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_parallels.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_parallels(.init(query: query))
    }
}

// MARK: - Cards API

/// Cards API endpoints
public class CardsAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI?) {
        self.client = client
    }

    /// Search cards across entire catalog
    /// - Parameters:
    ///   - query: Query parameters for filtering, pagination, and sorting
    /// - Returns: Paginated list of cards
    public func list(
        query: Operations.get_sol_v1_sol_catalog_sol_cards.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_cards(.init(query: query))
    }

    /// Get detailed information about a specific card
    /// - Parameter id: Card ID
    /// - Returns: Detailed card information
    public func get(id: String) async throws -> Operations.get_sol_v1_sol_catalog_sol_cards_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        let path = Operations.get_sol_v1_sol_catalog_sol_cards_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.get_sol_v1_sol_catalog_sol_cards_sol__lcub_id_rcub_(.init(path: path))
    }

    /// Get random cards matching the specified filters
    ///
    /// Returns random cards with optional parallel conversion odds system for simulating pack opening experiences.
    /// This endpoint supports all standard card filters and can optionally enable the parallel odds system.
    ///
    /// - Parameters:
    ///   - query: Query parameters for filtering and randomization options
    /// - Returns: Random cards (with optional parallel variants if `includeParallels=true`)
    ///
    /// # Example
    /// ```swift
    /// // Get 10 random cards from a specific set
    /// var query = Operations.get_sol_v1_sol_catalog_sol_cards_sol_random.Input.Query()
    /// query.count = 10
    /// query.setId = "set_uuid"
    /// let result = try await client.catalog.cards.random(query: query)
    ///
    /// // Simulate pack opening with parallels
    /// var packQuery = Operations.get_sol_v1_sol_catalog_sol_cards_sol_random.Input.Query()
    /// packQuery.count = 10
    /// packQuery.setId = "set_uuid"
    /// packQuery.includeParallels = true
    /// let pack = try await client.catalog.cards.random(query: packQuery)
    /// ```
    ///
    /// # Parallel Odds System
    ///
    /// When `includeParallels=true`, each card has a weighted probability of converting to a parallel variant:
    ///
    /// - **Numbered Parallels** (e.g., /1, /10, /99): Checked first, rarest to most common, with boosted odds
    /// - **Unlimited Parallels** (e.g., Refractor): One collective roll for all unlimited parallels
    /// - **Base Cards**: Returned if no parallel rolls succeed
    ///
    /// Cards returned with parallels will include `isParallel`, `parallelId`, `parallelName`, and `numberedTo` fields.
    ///
    /// - Note: If `count` exceeds available cards matching filters, returns all available cards without duplicates.
    /// - Note: `setId` and `releaseId` are mutually exclusive. Specifying both returns a 400 error.
    public func random(
        query: Operations.get_sol_v1_sol_catalog_sol_cards_sol_random.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_cards_sol_random.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_cards_sol_random(.init(query: query))
    }
}

// MARK: - Sets API

/// Sets API endpoints
public class SetsAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI?) {
        self.client = client
    }

    /// List and search card sets
    /// - Parameters:
    ///   - query: Query parameters for filtering, pagination, and sorting
    /// - Returns: Paginated list of sets
    public func list(
        query: Operations.get_sol_v1_sol_catalog_sol_sets.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_sets.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_sets(.init(query: query))
    }

    /// Get detailed information about a specific set
    /// - Parameter id: Set ID
    /// - Returns: Detailed set information including parallels
    public func get(id: String) async throws -> Operations.get_sol_v1_sol_catalog_sol_sets_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        let path = Operations.get_sol_v1_sol_catalog_sol_sets_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.get_sol_v1_sol_catalog_sol_sets_sol__lcub_id_rcub_(.init(path: path))
    }

    /// List cards within a specific set
    /// - Parameters:
    ///   - id: Set ID
    ///   - query: Query parameters for filtering, pagination, and sorting
    /// - Returns: Paginated list of cards in the set
    public func cards(
        id: String,
        query: Operations.get_sol_v1_sol_catalog_sol_sets_sol__lcub_id_rcub__sol_cards.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_sets_sol__lcub_id_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        let path = Operations.get_sol_v1_sol_catalog_sol_sets_sol__lcub_id_rcub__sol_cards.Input.Path(id: id)
        return try await client.raw.get_sol_v1_sol_catalog_sol_sets_sol__lcub_id_rcub__sol_cards(.init(path: path, query: query))
    }

    /// Get random sets matching the specified filters
    ///
    /// Returns random sets instead of paginated sorted results. Useful for discovery features,
    /// random browsing, or showcasing variety in the catalog. Supports all standard set filters.
    ///
    /// - Parameters:
    ///   - query: Query parameters for filtering and randomization options
    /// - Returns: Random sets matching the filters
    ///
    /// # Example
    /// ```swift
    /// // Get 3 random sets from a specific release
    /// var query = Operations.get_sol_v1_sol_catalog_sol_sets_sol_random.Input.Query()
    /// query.count = 3
    /// query.releaseId = "release_uuid"
    /// let result = try await client.catalog.sets.random(query: query)
    ///
    /// // Get 6 random sets from 2023
    /// var yearQuery = Operations.get_sol_v1_sol_catalog_sol_sets_sol_random.Input.Query()
    /// yearQuery.count = 6
    /// yearQuery.year = 2023
    /// let sets = try await client.catalog.sets.random(query: yearQuery)
    /// ```
    ///
    /// - Note: If `count` exceeds available sets matching filters, returns all available sets without duplicates.
    public func random(
        query: Operations.get_sol_v1_sol_catalog_sol_sets_sol_random.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_sets_sol_random.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_sets_sol_random(.init(query: query))
    }
}

// MARK: - Releases API

/// Releases API endpoints
public class ReleasesAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI?) {
        self.client = client
    }

    /// List and search releases
    /// - Parameters:
    ///   - query: Query parameters for filtering, pagination, and sorting
    /// - Returns: Paginated list of releases
    public func list(
        query: Operations.get_sol_v1_sol_catalog_sol_releases.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_releases.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_releases(.init(query: query))
    }

    /// Get detailed information about a specific release
    /// - Parameter id: Release ID
    /// - Returns: Detailed release information
    public func get(id: String) async throws -> Operations.get_sol_v1_sol_catalog_sol_releases_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        let path = Operations.get_sol_v1_sol_catalog_sol_releases_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.get_sol_v1_sol_catalog_sol_releases_sol__lcub_id_rcub_(.init(path: path))
    }

    /// List all cards in a release
    /// - Parameters:
    ///   - id: Release ID
    ///   - query: Query parameters for filtering, pagination, and sorting
    /// - Returns: Paginated list of cards in the release
    public func cards(
        id: String,
        query: Operations.get_sol_v1_sol_catalog_sol_releases_sol__lcub_id_rcub__sol_cards.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_releases_sol__lcub_id_rcub__sol_cards.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        let path = Operations.get_sol_v1_sol_catalog_sol_releases_sol__lcub_id_rcub__sol_cards.Input.Path(id: id)
        return try await client.raw.get_sol_v1_sol_catalog_sol_releases_sol__lcub_id_rcub__sol_cards(.init(path: path, query: query))
    }

    /// Get random releases matching the specified filters
    ///
    /// Returns random releases instead of paginated sorted results. Useful for discovery features,
    /// random browsing, or showcasing variety in the catalog. Supports all standard release filters
    /// including year, manufacturer, segment, and name search.
    ///
    /// - Parameters:
    ///   - query: Query parameters for filtering and randomization options
    /// - Returns: Random releases matching the filters
    ///
    /// # Example
    /// ```swift
    /// // Get 5 random releases from 2023
    /// var query = Operations.get_sol_v1_sol_catalog_sol_releases_sol_random.Input.Query()
    /// query.count = 5
    /// query.year = 2023
    /// let result = try await client.catalog.releases.random(query: query)
    ///
    /// // Get 10 random Topps releases
    /// var mfgQuery = Operations.get_sol_v1_sol_catalog_sol_releases_sol_random.Input.Query()
    /// mfgQuery.count = 10
    /// mfgQuery.manufacturerId = "topps_uuid"
    /// let releases = try await client.catalog.releases.random(query: mfgQuery)
    /// ```
    ///
    /// - Note: If `count` exceeds available releases matching filters, returns all available releases without duplicates.
    public func random(
        query: Operations.get_sol_v1_sol_catalog_sol_releases_sol_random.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_releases_sol_random.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_releases_sol_random(.init(query: query))
    }
}

// MARK: - Attributes API

/// Attributes API endpoints
public class AttributesAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI?) {
        self.client = client
    }

    /// Browse and search attributes with card counts
    /// - Parameters:
    ///   - query: Query parameters for filtering, pagination, and sorting
    /// - Returns: Paginated list of attributes with card counts
    public func list(
        query: Operations.get_sol_v1_sol_catalog_sol_attributes.Input.Query = .init()
    ) async throws -> Operations.get_sol_v1_sol_catalog_sol_attributes.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_catalog_sol_attributes(.init(query: query))
    }

    /// Get detailed information about a specific attribute
    /// - Parameter id: Attribute ID
    /// - Returns: Detailed attribute information
    public func get(id: String) async throws -> Operations.get_sol_v1_sol_catalog_sol_attributes_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }

        let path = Operations.get_sol_v1_sol_catalog_sol_attributes_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.get_sol_v1_sol_catalog_sol_attributes_sol__lcub_id_rcub_(.init(path: path))
    }
}