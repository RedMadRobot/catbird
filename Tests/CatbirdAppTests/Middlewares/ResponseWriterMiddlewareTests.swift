@testable import CatbirdApp
import Vapor
import XCTest

//final class ResponseWriterMiddlewareTests: RequestTestCase {
//
//    private var middleware: ResponseWriterMiddleware!
//    private var store: ResponseStoreMock!
//    private var request: Request!
//    private var responder: Responder!
//
//    override func setUp() {
//        super.setUp()
//        request = makeRequest()
//        store = ResponseStoreMock()
//        middleware = ResponseWriterMiddleware(store: store)
//    }
//
//    func _testWrite() {
//        let response = request.response("response from responder")
//        responder = ResponderMock { request in request.future(response) }
//
//        XCTAssertTrue(try respond() === response)
//        XCTAssertTrue(try store.response(for: request) === response)
//    }
//
//    // MARK: - Private
//
//    private func respond() throws -> Response {
//        return try middleware.respond(to: request, chainingTo: responder).wait()
//    }
//    
//}
