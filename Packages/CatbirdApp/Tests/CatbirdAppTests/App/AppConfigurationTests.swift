@testable import CatbirdApp
import XCTest

final class AppConfigurationTests: XCTestCase {

    func testDetectReadMode() throws {
        let config = try AppConfiguration.detect(from: [:])
        XCTAssertEqual(config.mode, .read)
        XCTAssertEqual(config.mocksDirectory.absoluteString, AppConfiguration.sourceDir)
        XCTAssertEqual(config.maxBodySize, "50mb")
    }

    func testDetectWriteMode() throws {
        let config = try AppConfiguration.detect(from: [
            "CATBIRD_PROXY_URL": "/",
            "CATBIRD_MAX_BODY_SIZE": "1kb"
        ])
        XCTAssertEqual(config.mode, .write(URL(string: "/")!))
        XCTAssertEqual(config.mocksDirectory.absoluteString, AppConfiguration.sourceDir)
        XCTAssertEqual(config.maxBodySize, "1kb")
    }

}
