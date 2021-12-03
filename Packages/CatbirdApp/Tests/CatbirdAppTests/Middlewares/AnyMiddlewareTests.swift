@testable import CatbirdApp
import Vapor
import XCTest

final class AnyMiddlewareTests: RequestTestCase {

    func testAbortNotFound() {
        // Given, When
        let future = AnyMiddleware.notFound {
            $0.eventLoop.makeSucceededFuture(Response(status: .ok))
        }
        .respond(to: request, chainingTo: AnyResponder {
            $0.eventLoop.makeFailedFuture(Abort(.notFound))
        })

        // Then
        XCTAssertEqual(try future.wait().status, .ok, "Catch abort error 404 and retrun 200")
    }

    func testResponseNotFound() {
        // Given, When
        let future = AnyMiddleware.notFound {
            $0.eventLoop.makeSucceededFuture(Response(status: .ok))
        }
        .respond(to: request, chainingTo: AnyResponder {
            $0.eventLoop.makeSucceededFuture(Response(status: .notFound))
        })

        // Then
        XCTAssertEqual(try future.wait().status, .ok, "Catch response 404 and retrun 200")
    }

    func testAbortBadRequest() {
        // Given, When
        let future = AnyMiddleware.notFound {
            $0.eventLoop.makeSucceededFuture(Response(status: .ok))
        }
        .respond(to: request, chainingTo: AnyResponder {
            $0.eventLoop.makeFailedFuture(Abort(.badRequest))
        })

        // Then
        XCTAssertThrowsError(try future.wait(), "Not catch abort error 400")
    }

    func testCapture() {
        // Given
        let response = Response(status: .ok)
        var captured: (request: Request, response: Response)?

        // When
        let future = AnyMiddleware.capture { request, response in
            captured = (request, response)
            return request.eventLoop.makeSucceededFuture(response)
        }.respond(to: request, chainingTo: AnyResponder {
            $0.eventLoop.makeSucceededFuture(response)
        })

        // Then
        XCTAssertNoThrow(try future.wait())
        XCTAssertTrue(captured?.request === request)
        XCTAssertTrue(captured?.response === response)
    }

}
