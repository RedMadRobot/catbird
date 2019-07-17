import Vapor

final class ResponseWriterMiddleware: Middleware, Service {

    private let store: ResponseWriter

    init(store: ResponseWriter) {
        self.store = store
    }

    /// Called with each `Request` that passes through this middleware.
    ///
    /// - SeeAlso: `Middleware`.
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        return try next
            .respond(to: request)
            .map { [store] (response: Response) throws in
                try store.setResponse(response, for: request)
                return response
            }
    }
}
