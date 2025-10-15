import Foundation

/// Feedback API endpoints for submitting user feedback
public class FeedbackAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    /// Submit general feedback
    /// - Parameter body: Feedback data
    /// - Returns: Feedback submission result
    public func general(
        body: Operations.post_sol_v1_sol_feedback_sol_general.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_feedback_sol_general.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.post_sol_v1_sol_feedback_sol_general(.init(body: body))
    }

    /// Submit card feedback
    /// - Parameters:
    ///   - id: Card ID
    ///   - body: Feedback data
    /// - Returns: Feedback submission result
    public func card(
        id: String,
        body: Operations.post_sol_v1_sol_feedback_sol_card_sol__lcub_id_rcub_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_feedback_sol_card_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_feedback_sol_card_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.post_sol_v1_sol_feedback_sol_card_sol__lcub_id_rcub_(.init(path: path, body: body))
    }

    /// Submit identify feedback
    /// - Parameters:
    ///   - id: Identification ID
    ///   - body: Feedback data
    /// - Returns: Feedback submission result
    public func identify(
        id: String,
        body: Operations.post_sol_v1_sol_feedback_sol_identify_sol__lcub_id_rcub_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_feedback_sol_identify_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_feedback_sol_identify_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.post_sol_v1_sol_feedback_sol_identify_sol__lcub_id_rcub_(.init(path: path, body: body))
    }

    /// Submit release feedback
    /// - Parameters:
    ///   - id: Release ID
    ///   - body: Feedback data
    /// - Returns: Feedback submission result
    public func release(
        id: String,
        body: Operations.post_sol_v1_sol_feedback_sol_release_sol__lcub_id_rcub_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_feedback_sol_release_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_feedback_sol_release_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.post_sol_v1_sol_feedback_sol_release_sol__lcub_id_rcub_(.init(path: path, body: body))
    }

    /// Submit set feedback
    /// - Parameters:
    ///   - id: Set ID
    ///   - body: Feedback data
    /// - Returns: Feedback submission result
    public func set(
        id: String,
        body: Operations.post_sol_v1_sol_feedback_sol_set_sol__lcub_id_rcub_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_feedback_sol_set_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_feedback_sol_set_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.post_sol_v1_sol_feedback_sol_set_sol__lcub_id_rcub_(.init(path: path, body: body))
    }

    /// Submit manufacturer feedback
    /// - Parameters:
    ///   - id: Manufacturer ID
    ///   - body: Feedback data
    /// - Returns: Feedback submission result
    public func manufacturer(
        id: String,
        body: Operations.post_sol_v1_sol_feedback_sol_manufacturer_sol__lcub_id_rcub_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_feedback_sol_manufacturer_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_feedback_sol_manufacturer_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.post_sol_v1_sol_feedback_sol_manufacturer_sol__lcub_id_rcub_(.init(path: path, body: body))
    }

    /// Submit segment feedback
    /// - Parameters:
    ///   - id: Segment ID
    ///   - body: Feedback data
    /// - Returns: Feedback submission result
    public func segment(
        id: String,
        body: Operations.post_sol_v1_sol_feedback_sol_segment_sol__lcub_id_rcub_.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_feedback_sol_segment_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.post_sol_v1_sol_feedback_sol_segment_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.post_sol_v1_sol_feedback_sol_segment_sol__lcub_id_rcub_(.init(path: path, body: body))
    }

    /// Get feedback by ID
    /// - Parameter id: Feedback ID
    /// - Returns: Feedback details
    public func get(
        id: String
    ) async throws -> Operations.get_sol_v1_sol_feedback_sol__lcub_id_rcub_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_feedback_sol__lcub_id_rcub_.Input.Path(id: id)
        return try await client.raw.get_sol_v1_sol_feedback_sol__lcub_id_rcub_(.init(path: path))
    }
}
