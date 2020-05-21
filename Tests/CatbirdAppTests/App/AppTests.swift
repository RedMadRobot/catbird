import CatbirdAPI
import CatbirdApp
import XCTVapor

final class AppTests: AppTestCase {

    func testStaticMock() throws {
        try app.test(.GET, "/Hello") { response in
            XCTAssertEqual(response.status.code, 200)
            XCTAssertEqual(response.body.string, "Hello from static file")
        }
    }

    func testAddMock() throws {
        // Given
        let mock = ResponseMock(status: 300, headers: ["X": "Y"], body: Data("hello".utf8))
        let pattern = RequestPattern(method: .GET, url: "/api/books", headers: ["X-Test": "1"])

        // When
        try app.perform(.update(pattern, mock))

        // Then
        try app.test(.GET, "api/books") { response in
            XCTAssertEqual(response.status, .notFound, "Missing header")
        }
        try app.test(.POST, "api/books") { response in
            XCTAssertEqual(response.status, .notFound, "Not correct method")
        }
        try app.test(.GET, "api/books", headers: ["X-Test": "1"]) { response in
            XCTAssertEqual(response.status.code, 300)
            XCTAssertEqual(response.headers.first(name: "X"), "Y")
            XCTAssertEqual(response.body.string, "hello")
        }
    }

    func testUpdateMock() throws {
        // Given
        var mock = ResponseMock(status: 200, body: Data("first".utf8))
        let pattern = RequestPattern(method: .GET, url: "/books")
        try app.perform(.update(pattern, mock))

        // When
        mock.body = Data("second".utf8)
        try app.perform(.update(pattern, mock))

        // Then
        try app.test(.GET, "/books", headers: ["X-Test": "1"]) { response in
            XCTAssertEqual(response.status.code, 200)
            XCTAssertEqual(response.body.string, "second", "Updated body")
        }
    }

    func testRemoveMock() throws {
        // Given
        let mock = ResponseMock(body: Data("John".utf8))
        let pattern = RequestPattern(method: .GET, url: "api/users/1")
        try app.perform(.update(pattern, mock))

        // When
        try app.perform(.update(pattern, nil))

        // Then
        try app.test(.POST, "api/users/1") { response in
            XCTAssertEqual(response.status, .notFound, "Mock not found")
        }
    }

    func testRemoveAllMocks() throws {
        // Given
        let mock = ResponseMock(body: Data("Kid".utf8))
        try app.perform(.update(RequestPattern(method: .GET, url: "/users/1"), mock))
        try app.perform(.update(RequestPattern(method: .GET, url: "/users/2"), mock))
        try app.perform(.update(RequestPattern(method: .GET, url: "/users/3"), mock))

        // When
        try app.perform(.removeAll)

        // Then
        try app.test(.POST, "/users/1") { response in
            XCTAssertEqual(response.status, .notFound, "Mock not found")
        }
        try app.test(.POST, "/users/2") { response in
            XCTAssertEqual(response.status, .notFound, "Mock not found")
        }
        try app.test(.POST, "/users/3") { response in
            XCTAssertEqual(response.status, .notFound, "Mock not found")
        }
    }
}
