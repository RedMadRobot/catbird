@testable import CatbirdApp
import XCTest

final class AppConfigTests: XCTestCase {

    func testDetect() {
        XCTAssertNoThrow(try {
            let config = try AppConfig.detect(from: [:])
            XCTAssertEqual(config.mode, .read)
            XCTAssertEqual(config.mocksDirectory, AppConfig.sourceDir + "/Mocks")
        }(), "Detect app config from empty environment")

        XCTAssertNoThrow(try {
            let config = try AppConfig.detect(from: [
                "CATBIRD_PROXY_URL": "/"
            ])
            XCTAssertEqual(config.mode, .write(URL(string: "/")!))
            XCTAssertEqual(config.mocksDirectory, AppConfig.sourceDir + "/Mocks")
        }(), "Detect reader app config")
    }

}
