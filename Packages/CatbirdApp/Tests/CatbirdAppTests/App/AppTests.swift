import CatbirdAPI
import CatbirdApp
import XCTVapor

final class AppTests: AppTestCase {

    func testReadFileMock() throws {
        try app.test(.GET, "/api/books/1") { response in
            XCTAssertEqual(response.status.code, 200)
            XCTAssertEqual(response.body.string, "first book\n")
        }
    }

    func testWriteFileMock() throws {
        // Given
        let api = JokeAPI()
        XCTAssertNoThrow(try setUpApp(mode: .write(api.host)), """
        Launch the app in redirect mode to \(api.host) and write files to a folder \(mocksDirectory)
        """)
        addTeardownBlock {
            let path = self.mocksDirectory + api.root
            XCTAssertNotNil(try? FileManager.default.removeItem(atPath: path), """
            Remove created files and directories at \(path)
            """)
        }

        // When
        for joke in api.jokes {
            try app.test(.GET, joke.path, headers: api.headers) { response in
                XCTAssertEqual(response.status.code, 200)
                XCTAssertEqual(response.body.string, joke.text, """
                Returned the joke by index \(joke.id)
                """)
            }
        }

        // Then
        for joke in api.jokes {
            let path = mocksDirectory + joke.path + ".txt"
            XCTAssertEqual(try String(contentsOfFile: path), joke.text, """
            The joke by \(joke.id) was saved to a file at path \(path)
            """)
        }
    }

    func testAddMock() throws {
        // Given
        let mock = ResponseMock(status: 300, headers: ["X": "Y"], body: Data("hello".utf8))
        let pattern = RequestPattern(method: .GET, url: "/books", headers: ["X-Test": "1"])

        // When
        try app.perform(.update(pattern, mock))

        // Then
        try app.test(.GET, "/books") { response in
            XCTAssertEqual(response.status, .notFound, "Missing header")
        }
        try app.test(.POST, "/books") { response in
            XCTAssertEqual(response.status, .notFound, "Not correct method")
        }
        try app.test(.GET, "/books", headers: ["X-Test": "1"]) { response in
            XCTAssertEqual(response.status.code, 300)
            XCTAssertEqual(response.headers.first(name: "X"), "Y")
            XCTAssertEqual(response.body.string, "hello")
        }
    }

    func testAddMockOverStaticFile() throws {
        // Given
        let mock = ResponseMock(status: 200, body: Data("dynamic mock".utf8))
        let pattern = RequestPattern(method: .GET, url: "/api/books/1")

        try app.test(.GET, "/api/books/1") { response in
            XCTAssertEqual(response.status.code, 200)
            XCTAssertEqual(response.body.string, "first book\n")
        }

        // When
        try app.perform(.update(pattern, mock))

        // Then
        try app.test(.GET, "/api/books/1") { response in
            XCTAssertEqual(response.status.code, 200)
            XCTAssertEqual(response.body.string, "dynamic mock")
        }
    }

    func testUpdateMock() throws {
        // Given
        var mock = ResponseMock(status: 200, body: Data("first".utf8))
        let pattern = RequestPattern(method: .GET, url: "/books/2")
        try app.perform(.update(pattern, mock))

        // When
        mock.body = Data("second".utf8)
        try app.perform(.update(pattern, mock))

        // Then
        try app.test(.GET, "/books/2", headers: ["X-Test": "1"]) { response in
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
        try app.perform(.remove(pattern))

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
