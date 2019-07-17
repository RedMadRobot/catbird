import CatbirdAPI
@testable import CatbirdApp
import Vapor
import XCTest

final class ResponseReaderMiddlewareTests: RequestTestCase {

    private var middleware: ResponseReaderMiddleware!
    private var store: ResponseStoreMock!
    private var request: Request!
    private var responder: Responder!

    override func setUp() {
        super.setUp()
        request = makeRequest()
        store = ResponseStoreMock()
        middleware = ResponseReaderMiddleware(store: store)
    }

    func testResponseFromStore() {
        let response = request.response("response from store")
        responder = ResponderMock.notFound
        try! store.setResponse(response, for: request)

        XCTAssertTrue(try respond() === response)
    }

    func testResponseFromResponder() {
        let response = request.response("response from responder")
        responder = ResponderMock { request in request.future(response) }

        XCTAssertTrue(try respond() === response)
    }

    func testUnknownError() {
        responder = ResponderMock { _ in throw TestError.unknown }

        XCTAssertThrowsError(try respond())
    }

    // MARK: - Private

    private func respond() throws -> Response {
        return try middleware.respond(to: request, chainingTo: responder).wait()
    }
}
