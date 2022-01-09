@testable import CatbirdApp
import CatbirdAPI
import XCTest

final class MIMETypeTests: RequestTestCase {

    func testPreferredFilenameExtension() {
        XCTAssertEqual(MIMEType("application/json").preferredFilenameExtension, "json")
        XCTAssertEqual(MIMEType("text/html").preferredFilenameExtension, "html")
    }

    func testRequestAccept() {
        XCTAssertEqual(makeRequest(headers: ["Accept": "text/html"]).accept, [
            MIMEType("text/html")
        ])
        XCTAssertEqual(makeRequest(headers: ["Accept": "image/*"]).accept, [
            MIMEType("image/*")
        ])
        XCTAssertEqual(makeRequest(headers: ["Accept": "text/html, application/json"]).accept, [
            MIMEType("text/html"),
            MIMEType("application/json")
        ])
    }
}
