@testable import CatbirdApp
import XCTest

final class AppConfigurationTests: XCTestCase {

    func testDetectReadMode() throws {
        let config = try AppConfiguration.detect(from: [:])
        XCTAssertEqual(config.isRecordMode, false)
        XCTAssertEqual(config.proxyEnabled, false)
        XCTAssertEqual(config.mocksDirectory.absoluteString, AppConfiguration.sourceDir)
        XCTAssertNil(config.redirectUrl)
        XCTAssertEqual(config.maxBodySize, "50mb")
    }

    func testDetectWriteMode() throws {
        let config = try AppConfiguration.detect(from: [
            "CATBIRD_RECORD_MODE": "1",
            "CATBIRD_PROXY_ENABLED": "1",
            "CATBIRD_REDIRECT_URL": "https://example.com",
            "CATBIRD_MAX_BODY_SIZE": "1kb"
        ])
        XCTAssertEqual(config.isRecordMode, true)
        XCTAssertEqual(config.proxyEnabled, true)
        XCTAssertEqual(config.mocksDirectory.absoluteString, AppConfiguration.sourceDir)
        XCTAssertEqual(config.redirectUrl?.absoluteString, "https://example.com")
        XCTAssertEqual(config.maxBodySize, "1kb")
    }

}
