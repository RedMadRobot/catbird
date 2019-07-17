import Vapor

final class ResponseReaderMiddleware: Middleware, Service {

    private let store: ResponseReader

    init(store: ResponseReader) {
        self.store = store
    }

    /// Called with each `Request` that passes through this middleware.
    ///
    /// - SeeAlso: `Middleware`.
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        return next
            .handle(request)
            .catchMap { [store] (error: Error) throws -> Response in
                guard error is Abort else { throw error }
                return try store.response(for: request)
            }
    }

}

private extension Responder {
    func handle(_ request: Request) -> Future<Response> {
        do {
            return try self.respond(to: request)
        } catch {
            return request.eventLoop.newFailedFuture(error: error)
        }
    }
}
