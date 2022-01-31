import Vapor

final class AnyMiddleware: Middleware {

    typealias Handler = (Request, Responder) -> EventLoopFuture<Response>

    private let handler: Handler

    init(handler: @escaping Handler) {
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
            responder.respond(to: request).notFound {
                handler(request)
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

extension EventLoopFuture where Value: Response {
    func notFound(
        _ handler: @escaping () -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Response> {

        return flatMap { [eventLoop] (response: Response) -> EventLoopFuture<Response> in
            if response.status == .notFound {
                return handler()
            }
            return eventLoop.makeSucceededFuture(response)
        }
        .flatMapError { [eventLoop] (error: Error) -> EventLoopFuture<Response> in
            if let abort = error as? AbortError, abort.status == .notFound {
                return handler()
            }
            return eventLoop.makeFailedFuture(error)
        }
    }
}
