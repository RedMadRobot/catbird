@testable import CatbirdAPI
import XCTest

final class CatbirdActionTests: XCTestCase {
    private let decoder = JSONDecoder()
    private let baseURL = URL(string: "https://example.com")!
    private var expectedURL: URL {
        baseURL.appendingPathComponent("catbird/api/mocks")
    }

    func testUpdate() throws {
        // Given
        let pattern = RequestPattern(method: .GET, url: "/about")
        let response = ResponseMock(status: 200, body: Data("hello".utf8))
        let action = CatbirdAction.update(pattern, response)

        // When
        let request = try XCTUnwrap(try action.makeRequest(to: baseURL))

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(try request.httpBody.map {
            try decoder.decode(CatbirdAction.self, from: $0)
        }, action)
    }

    func testRemove() throws {
        // Given
        let pattern = RequestPattern(method: .GET, url: "/about")
        let action = CatbirdAction.update(pattern, nil)

        // When
        let request = try XCTUnwrap(try action.makeRequest(to: baseURL))

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(try request.httpBody.map {
            try decoder.decode(CatbirdAction.self, from: $0)
        }, action)
    }

    func testRemoveAll() throws {
        // Given
        let action = CatbirdAction.removeAll

        // When
        let request = try XCTUnwrap(try action.makeRequest(to: baseURL))

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(try request.httpBody.map {
            try decoder.decode(CatbirdAction.self, from: $0)
        }, action)
    }
}
