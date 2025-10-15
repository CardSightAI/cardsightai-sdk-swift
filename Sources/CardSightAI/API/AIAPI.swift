import Foundation

/// AI API endpoints for natural language queries
public class AIAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    /// Query the AI with natural language
    /// - Parameter body: Query data including the natural language question
    /// - Returns: AI response with relevant cards/data
    public func query(
        body: Operations.post_sol_v1_sol_ai_sol_query.Input.Body
    ) async throws -> Operations.post_sol_v1_sol_ai_sol_query.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.post_sol_v1_sol_ai_sol_query(.init(body: body))
    }
}
