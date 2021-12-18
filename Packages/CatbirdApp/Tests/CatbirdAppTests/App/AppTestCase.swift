@testable import CatbirdApp
import XCTVapor

class AppTestCase: XCTestCase {

    let mocksDirectory = AppConfiguration.sourceDir + "/Tests/CatbirdAppTests/Files"

    private(set) var app: Application! {
        willSet { app?.shutdown() }
    }

    func setUpApp(mode: AppConfiguration.Mode) throws {
        let config = AppConfiguration(
            mode: mode,
            mocksDirectory: URL(string: mocksDirectory)!,
            maxBodySize: "50kb")
        app = Application(.testing)
        try configure(app, config)
    }

    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try setUpApp(mode: .read))
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

    func makeRequest(headers: HTTPHeaders = [:]) -> Request {
        Request(application: app, headers: headers, on: app.eventLoopGroup.next())
    }
}
