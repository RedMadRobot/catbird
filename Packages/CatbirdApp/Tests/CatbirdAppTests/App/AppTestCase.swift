@testable import CatbirdApp
import XCTVapor

class AppTestCase: XCTestCase {

    let mocksDirectory = AppConfiguration.sourceDir + "/Tests/CatbirdAppTests/Files"

    private(set) var app: Application! {
        willSet { app?.shutdown() }
    }

    func setUpApp(redirectUrl: URL?) throws {
        let config = AppConfiguration(
            isRecordMode: redirectUrl != nil,
            proxyEnabled: false,
            mocksDirectory: URL(string: mocksDirectory)!,
            redirectUrl: redirectUrl,
            maxBodySize: "50kb")
        app = Application(.testing)
        try configure(app, config)
    }

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try setUpApp(redirectUrl: nil))
        XCTAssertEqual(app.routes.defaultMaxBodySize, 51200)
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }
}

class RequestTestCase: AppTestCase {

    private(set) var request: Request!

    override func setUp() {
        super.setUp()
        let eventLoop = app.eventLoopGroup.next()
        request = Request(application: app, on: eventLoop)
    }

    func makeRequest(url: URI = "/", headers: HTTPHeaders = [:]) -> Request {
        Request(application: app, url: url, headers: headers, on: app.eventLoopGroup.next())
    }
}
