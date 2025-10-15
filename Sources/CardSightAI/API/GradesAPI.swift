import Foundation

/// Grades API endpoints for grading companies and grades
public class GradesAPI {
    private weak var client: CardSightAI?

    init(client: CardSightAI) {
        self.client = client
    }

    /// Get all grading companies
    /// - Returns: List of grading companies (PSA, BGS, SGC, etc.)
    public func companies() async throws -> Operations.get_sol_v1_sol_grades_sol_companies.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        return try await client.raw.get_sol_v1_sol_grades_sol_companies(.init())
    }

    /// Get grading types for a specific company
    /// - Parameter companyId: Company ID
    /// - Returns: Grading types for the company
    public func types(
        companyId: String
    ) async throws -> Operations.get_sol_v1_sol_grades_sol_companies_sol__lcub_companyId_rcub__sol_types.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_grades_sol_companies_sol__lcub_companyId_rcub__sol_types.Input.Path(companyId: companyId)
        return try await client.raw.get_sol_v1_sol_grades_sol_companies_sol__lcub_companyId_rcub__sol_types(.init(path: path))
    }

    /// Get grades for a specific grading type
    /// - Parameters:
    ///   - companyId: Company ID
    ///   - typeId: Grading type ID
    /// - Returns: Grades for the grading type
    public func grades(
        companyId: String,
        typeId: String
    ) async throws -> Operations.get_sol_v1_sol_grades_sol_companies_sol__lcub_companyId_rcub__sol_types_sol__lcub_typeId_rcub__sol_grades.Output {
        guard let client = client else {
            throw CardSightAIError.unknown("Client has been deallocated")
        }
        let path = Operations.get_sol_v1_sol_grades_sol_companies_sol__lcub_companyId_rcub__sol_types_sol__lcub_typeId_rcub__sol_grades.Input.Path(
            companyId: companyId,
            typeId: typeId
        )
        return try await client.raw.get_sol_v1_sol_grades_sol_companies_sol__lcub_companyId_rcub__sol_types_sol__lcub_typeId_rcub__sol_grades(.init(path: path))
    }
}
