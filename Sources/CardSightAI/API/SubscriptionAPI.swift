import Foundation

/// Subscription API endpoints for subscription information
public class SubscriptionAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    /// Get subscription information
    /// - Returns: Current subscription details
    public func get() async throws -> Operations.get_sol_v1_sol_subscription_sol_.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_subscription_sol_(.init())
    }
}
