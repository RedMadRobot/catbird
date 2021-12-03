import Vapor

final class ProxyMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Not handle direct request to catbird
//        guard let url = URL(string: request.url.string) else {
//            return next.respond(to: request)
//        }
//        print(url)

        if request.url.host == nil {
            request.logger.info("Proxy break \(request.method) \(request.url)")
            return next.respond(to: request)
        }

//        request.logger.info("Proxy \(request.method) \(url), scheme \(request.url.scheme ?? "<nil>")")

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
