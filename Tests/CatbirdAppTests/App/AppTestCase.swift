@testable import CatbirdApp
import XCTVapor

class AppTestCase: XCTVaporTests {

    class var config: AppConfiguration {
        let mocks = URL(string: AppConfiguration.sourceDir + "/Tests/CatbirdAppTests/Files")!
        return AppConfiguration(mode: .read, mocksDirectory: mocks)
    }

    override class func setUp() {
        super.setUp()
        XCTVapor.app = {
            let app = Application(.testing)
            try configure(app, config)
            return app
        }
    }
}

class RequestTestCase: AppTestCase {

    private(set) var request: Request!

    override func setUp() {
        super.setUp()
        let eventLoop = app.eventLoopGroup.next()
        request = Request(application: app, on: eventLoop)
    }
}
