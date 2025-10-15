import XCTest
@testable import CardSightAI

final class CardSightAITests: XCTestCase {

    // MARK: - Configuration Tests

    func testConfigurationWithAPIKey() throws {
        let config = try CardSightAIConfig(apiKey: "test_api_key")
        XCTAssertEqual(config.apiKey, "test_api_key")
        XCTAssertEqual(config.baseURL, "https://api.cardsight.ai")
        XCTAssertEqual(config.timeout, 30)
        XCTAssertTrue(config.autoProcessImages)
    }

    func testConfigurationFromEnvironment() throws {
        // Set environment variable
        setenv("CARDSIGHTAI_API_KEY", "env_api_key", 1)
        defer { unsetenv("CARDSIGHTAI_API_KEY") }

        let config = try CardSightAIConfig()
        XCTAssertEqual(config.apiKey, "env_api_key")
    }

    func testConfigurationMissingAPIKeyThrows() {
        // Ensure no environment variable
        unsetenv("CARDSIGHTAI_API_KEY")

        XCTAssertThrowsError(try CardSightAIConfig()) { error in
            guard let cardSightError = error as? CardSightAIError else {
                XCTFail("Expected CardSightAIError")
                return
            }

            switch cardSightError {
            case .authenticationError:
                // Expected
                break
            default:
                XCTFail("Expected authentication error")
            }
        }
    }

    func testConfigurationWithImageProcessingOptions() throws {
        let config = try CardSightAIConfig(
            apiKey: "test_key",
            timeout: 60,
            imageProcessing: ImageProcessingOptions(
                maxDimension: 1024,
                jpegQuality: 0.7,
                maxFileSizeMB: 3.0
            ),
            autoProcessImages: false
        )

        XCTAssertEqual(config.apiKey, "test_key")
        XCTAssertEqual(config.baseURL, "https://api.cardsight.ai")
        XCTAssertEqual(config.timeout, 60)
        XCTAssertEqual(config.imageProcessing.maxDimension, 1024)
        XCTAssertEqual(config.imageProcessing.jpegQuality, 0.7)
        XCTAssertEqual(config.imageProcessing.maxFileSizeMB, 3.0)
        XCTAssertFalse(config.autoProcessImages)
    }

    // MARK: - Image Processing Options Tests

    func testImageProcessingOptionsDefaults() {
        let options = ImageProcessingOptions()
        XCTAssertEqual(options.maxDimension, 2048)
        XCTAssertEqual(options.jpegQuality, 0.8)
        XCTAssertEqual(options.maxFileSizeMB, 5.0)
        XCTAssertTrue(options.correctOrientation)
    }

    func testImageProcessingOptionsQualityClamp() {
        let optionsHigh = ImageProcessingOptions(jpegQuality: 1.5)
        XCTAssertEqual(optionsHigh.jpegQuality, 1.0)

        let optionsLow = ImageProcessingOptions(jpegQuality: -0.5)
        XCTAssertEqual(optionsLow.jpegQuality, 0.0)
    }

    // MARK: - Error Tests

    func testErrorDescriptions() {
        let authError = CardSightAIError.authenticationError("Invalid API key")
        XCTAssertEqual(authError.errorDescription, "Authentication Error: Invalid API key")
        XCTAssertTrue(authError.isAuthenticationError)
        XCTAssertFalse(authError.isNetworkError)

        let apiError = CardSightAIError.apiError(statusCode: 404, message: "Not found", response: nil)
        XCTAssertEqual(apiError.errorDescription, "API Error (404): Not found")
        XCTAssertEqual(apiError.statusCode, 404)
        XCTAssertFalse(apiError.isRetryable)

        let serverError = CardSightAIError.apiError(statusCode: 500, message: "Server error", response: nil)
        XCTAssertTrue(serverError.isRetryable)

        let rateLimitError = CardSightAIError.apiError(statusCode: 429, message: "Rate limited", response: nil)
        XCTAssertTrue(rateLimitError.isRetryable)

        let timeoutError = CardSightAIError.timeout
        XCTAssertTrue(timeoutError.isNetworkError)
        XCTAssertTrue(timeoutError.isRetryable)
    }

    // MARK: - Client Initialization Tests

    func testClientInitialization() throws {
        let config = try CardSightAIConfig(apiKey: "test_key")
        let client = try CardSightAI(config: config)
        XCTAssertNotNil(client)
        XCTAssertEqual(client.config.apiKey, "test_key")
    }

    func testClientConvenienceInitializer() throws {
        let client = try CardSightAI(apiKey: "test_key")
        XCTAssertNotNil(client)
        XCTAssertEqual(client.config.apiKey, "test_key")
    }

    func testClientUsesProductionAPI() throws {
        let client = try CardSightAI(apiKey: "test_key")
        XCTAssertEqual(client.config.baseURL, "https://api.cardsight.ai",
                      "Client should always use production CardSight AI API")
    }

    // MARK: - Image Processor Tests

    func testImageProcessorInitialization() {
        let processor = ImageProcessor()
        XCTAssertNotNil(processor)

        let customOptions = ImageProcessingOptions(maxDimension: 1024)
        let customProcessor = ImageProcessor(options: customOptions)
        XCTAssertNotNil(customProcessor)
    }

    func testImageFormatDetection() async throws {
        let processor = ImageProcessor()

        // Test JPEG detection
        let jpegData = Data([0xFF, 0xD8, 0xFF, 0xE0])
        let jpegMirror = Mirror(reflecting: processor)
        if let isJPEGMethod = jpegMirror.descendant("isJPEGFormat") as? (Data) -> Bool {
            XCTAssertTrue(isJPEGMethod(jpegData))
        }

        // Test PNG detection
        let pngData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        if let isPNGMethod = jpegMirror.descendant("isPNGFormat") as? (Data) -> Bool {
            XCTAssertTrue(isPNGMethod(pngData))
        }

        // Note: Full HEIC detection test would require actual HEIC data
    }
}

// MARK: - Mock Tests

final class CardSightAIMockTests: XCTestCase {

    func testMockHealthCheck() async throws {
        // This would use a mock server or stubbed responses in a real implementation
        // For now, just ensure the API structure compiles correctly

        let config = try CardSightAIConfig(apiKey: "test_key")
        let client = try CardSightAI(config: config)

        // Verify API endpoints are accessible
        XCTAssertNotNil(client.health)
        XCTAssertNotNil(client.identify)
        XCTAssertNotNil(client.catalog)
        XCTAssertNotNil(client.collections)
        XCTAssertNotNil(client.collectors)
        XCTAssertNotNil(client.lists)
        XCTAssertNotNil(client.grades)
        XCTAssertNotNil(client.autocomplete)
        XCTAssertNotNil(client.ai)
        XCTAssertNotNil(client.images)
        XCTAssertNotNil(client.feedback)
        XCTAssertNotNil(client.subscription)
    }
}

// MARK: - Integration Tests

/// Integration tests that make real API calls to validate connectivity
/// These tests require a valid API key set via CARDSIGHTAI_API_KEY environment variable
/// Run with: swift test --enable-test-discovery
final class CardSightAIIntegrationTests: XCTestCase {

    /// Test the unauthenticated health check endpoint
    /// This validates basic API connectivity without requiring an API key
    /// Endpoint: GET /health
    func testHealthCheckUnauthenticated() async throws {
        // Skip if running in CI or automated testing
        try XCTSkipIf(ProcessInfo.processInfo.environment["CI"] != nil, "Skipping integration test in CI")

        // Create client with dummy API key (not needed for unauthenticated endpoint)
        let client = try CardSightAI(apiKey: "dummy_key_for_health_check")

        // Call unauthenticated health endpoint
        let response = try await client.health.check()

        // Verify response
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let healthResponse):
                XCTAssertTrue(healthResponse.status == "ok" || healthResponse.status == "healthy",
                             "Health check should return 'ok' or 'healthy' status")
                print("✅ Health check (unauthenticated): \(healthResponse.status)")
            }
        default:
            XCTFail("Expected .ok response from health check")
        }
    }

    /// Test the authenticated health check endpoint
    /// This validates both API connectivity and API key validity
    /// Endpoint: GET /health/auth
    /// Requires: CARDSIGHTAI_API_KEY environment variable
    func testHealthCheckAuthenticated() async throws {
        // Skip if running in CI or automated testing
        try XCTSkipIf(ProcessInfo.processInfo.environment["CI"] != nil, "Skipping integration test in CI")

        // Skip if no API key is provided
        guard let apiKey = ProcessInfo.processInfo.environment["CARDSIGHTAI_API_KEY"], !apiKey.isEmpty else {
            throw XCTSkip("Skipping authenticated health check - set CARDSIGHTAI_API_KEY environment variable to run this test")
        }

        // Create client with real API key from environment
        let client = try CardSightAI(apiKey: apiKey)

        // Call authenticated health endpoint
        let response = try await client.health.checkAuth()

        // Verify response
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let healthResponse):
                XCTAssertTrue(healthResponse.status == "ok" || healthResponse.status == "healthy",
                             "Authenticated health check should return 'ok' or 'healthy' status")
                print("✅ Health check (authenticated): \(healthResponse.status)")
                print("✅ API key is valid and working correctly")
            }
        case .unauthorized:
            XCTFail("Authentication failed - verify your CARDSIGHTAI_API_KEY is valid")
        default:
            XCTFail("Expected .ok response from authenticated health check")
        }
    }
}