import Vapor

final class AnyMiddleware: Middleware {

    private typealias Handler = (Request, Responder) -> EventLoopFuture<Response>

    private let handler: Handler

    private init(handler: @escaping Handler) {
        self.handler = handler
    }

    // MARK: - Middleware

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return handler(request, next)
    }
}

extension AnyMiddleware {
    /// A route not found.
    ///
    /// - Parameter handler: http request handler.
    /// - Returns: A new `Middleware`.
    static func notFound(_ handler: @escaping (Request) -> EventLoopFuture<Response>) -> Middleware {
        AnyMiddleware { (request, responder) -> EventLoopFuture<Response> in
            responder.respond(to: request)
                .flatMap { (response: Response) -> EventLoopFuture<Response> in
                    if response.status == .notFound {
                        return handler(request)
                    }
                    return request.eventLoop.makeSucceededFuture(response)
                }
                .flatMapError { (error: Error) -> EventLoopFuture<Response> in
                    if let abort = error as? AbortError, abort.status == .notFound {
                        return handler(request)
                    }
                    return request.eventLoop.makeFailedFuture(error)
                }
        }
    }

    static func capture(_ handle: @escaping (Request, Response) -> EventLoopFuture<Response>) -> Middleware {
        AnyMiddleware { (request, responder) -> EventLoopFuture<Response> in
            responder.respond(to: request).flatMap { (response: Response) in
                handle(request, response)
            }
        }
    }

}
