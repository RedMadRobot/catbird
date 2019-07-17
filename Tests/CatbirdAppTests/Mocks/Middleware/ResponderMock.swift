import Vapor

final class ResponderMock: Responder {
    typealias RequestHandler = (Request) throws -> Future<Response>

    private let requestHandler: RequestHandler

    init(requestHandler: @escaping RequestHandler) {
        self.requestHandler = requestHandler
    }

    /// Alway return not found error.
    static let notFound = ResponderMock { _ in throw Abort(.notFound) }

    // MARK: - Responder

    func respond(to req: Request) throws -> Future<Response> {
        return try requestHandler(req)
    }
}
