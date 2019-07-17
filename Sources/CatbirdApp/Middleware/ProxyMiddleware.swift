import Vapor

/// Proxy middleware to another server.
final class ProxyMiddleware: Middleware, Service {

    /// A server url.
    private let baseURL: URL

    /// Request/Response logger.
    private let logger: Logger

    /// Creates a new `ProxyMiddleware`.
    ///
    /// - Parameters:
    ///   - baseURL: A server url.
    ///   - logger: Request/Response logger.
    init(baseURL: URL, logger: Logger) {
        self.baseURL = baseURL
        self.logger = logger
    }

    /// Called with each `Request` that passes through this middleware.
    ///
    /// - SeeAlso: `Middleware`.
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        // Redirect to another server
        request.http.urlString = baseURL.absoluteString + request.http.urlString

        return try request
            .client()
            .send(request)
            .catch { (error: Error) in
                self.logger.report(error: error)
            }
    }
}
