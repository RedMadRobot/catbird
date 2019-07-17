import Vapor
import XCTest

enum TestError: Error {
    case unknown
}

class RequestTestCase: XCTestCase {

    private var worker: Worker!

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()
        worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override func tearDown() {
        super.tearDown()
        XCTAssertNoThrow(try worker.syncShutdownGracefully())
    }

    // MARK: - Request

    func makeRequest(http: HTTPRequest = HTTPRequest()) -> Request {
        return Request(http: http, using: makeContainer())
    }

    private func makeContainer() -> Container {
        return BasicContainer(
            config: Config.default(),
            environment: Environment.testing,
            services: Services.default(),
            on: worker)
    }

}
