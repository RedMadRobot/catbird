import Vapor

final class ProxyMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if request.url.host == nil {
            request.logger.info("Proxy break \(request.method) \(request.url)")
            return next.respond(to: request)
        }
        return next.respond(to: request).notFound {
            var url = request.url
            if url.scheme == nil {
                url.scheme = url.port == 443 ? "https" : "http"
            }

            request.logger.info("Proxy \(request.method) \(url), scheme \(url.scheme ?? "<nil>")")

            // Send request to real host
            return request.send {
                $0.url = url
            }
        }
    }
}
