import Vapor

final class RedirectMiddleware: Middleware {

    private let redirectURI: URI

    init(serverURL: URL) {
        self.redirectURI = URI(string: serverURL.absoluteString)
    }

    // MARK: - Middleware

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Handle only direct requests to catbird
        if request.url.host != nil {
            return next.respond(to: request) // proxy request
        }

        var uri = redirectURI
        uri.string += request.url.string

        // Send request to redirect host
        return request.send {
            $0.url = uri
        }
    }
}
