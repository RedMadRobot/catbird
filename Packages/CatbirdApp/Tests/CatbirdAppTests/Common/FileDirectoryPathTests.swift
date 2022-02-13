@testable import CatbirdApp
import XCTest

final class FileDirectoryPathTests: RequestTestCase {

    func testPreferredFileURL() {
        let path = FileDirectoryPath(url: URL(string: "stubs")!)
        let request = makeRequest(
            url: "/news",
            headers: ["Accept": "text/html, application/json"]
        )
        XCTAssertEqual(
            path.preferredFileURL(for: request),
            URL(string: "stubs/news.html")!
        )
    }

    func testPreferredFileURLForURLWithPathExtension() {
        let path = FileDirectoryPath(url: URL(string: "mocks")!)
        let request = makeRequest(
            url: "/user.json",
            headers: ["Accept": "application/text"]
        )
        XCTAssertEqual(
            path.preferredFileURL(for: request),
            URL(string: "mocks/user.json")!
        )
    }

    func testFilePathsForRequestWithAccept() {
        let path = FileDirectoryPath(url: URL(string: "files")!)
        let request = makeRequest(
            url: "/item/1",
            headers: [:]
        )
        XCTAssertEqual(path.filePaths(for: request), [
            "files/item/1",
        ])
    }

    func testFilePathsForRequestWithEmptyAccept() {
        let path = FileDirectoryPath(url: URL(string: "fixtures")!)
        let request = makeRequest(
            url: "/stores",
            headers: ["Accept": "text/plain, application/json"]
        )
        XCTAssertEqual(path.filePaths(for: request), [
            "fixtures/stores.txt",
            "fixtures/stores.json",
            "fixtures/stores"
        ])
    }

    func testRequestWithHost() {
        let path = FileDirectoryPath(url: URL(string: "root")!)
        let request = makeRequest(
            url: "http://example.com/news.html"
        )
        XCTAssertEqual(
            path.preferredFileURL(for: request),
            URL(string: "root/example.com/news.html")!
        )
        XCTAssertEqual(path.filePaths(for: request), [
            "root/example.com/news.html",
        ])
    }

    func testRequestWithSlash() {
        let path = FileDirectoryPath(url: URL(string: "root")!)
        let request = makeRequest(
            url: "http://example.com/",
            headers: ["Accept": "text/html"]
        )
        XCTAssertEqual(
            path.preferredFileURL(for: request),
            URL(string: "root/example.com/index.html")!
        )
        XCTAssertEqual(path.filePaths(for: request), [
            "root/example.com/index.html",
            "root/example.com/index",
        ])
    }

    func testRequestWithQuery() {
        let path = FileDirectoryPath(url: URL(string: "root")!)
        let request = makeRequest(
            url: "http://example.com/item?data=123"
        )
        XCTAssertEqual(
            path.preferredFileURL(for: request),
            URL(string: "root/example.com/item")!
        )
        XCTAssertEqual(path.filePaths(for: request), [
            "root/example.com/item",
        ])
    }
}
