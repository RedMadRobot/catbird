@testable import CatbirdApp
import XCTest

final class AppConfigurationTests: XCTestCase {

    func testDetectReadMode() throws {
        let config = try AppConfiguration.detect(from: [:])
        XCTAssertEqual(config.mode, .read)
        XCTAssertEqual(config.mocksDirectory.absoluteString, AppConfiguration.sourceDir)
    }

    func testDetectWriteMode() throws {
        let config = try AppConfiguration.detect(from: [
            "CATBIRD_PROXY_URL": "/"
        ])
        XCTAssertEqual(config.mode, .write(URL(string: "/")!))
        XCTAssertEqual(config.mocksDirectory.absoluteString, AppConfiguration.sourceDir)
    }

}
