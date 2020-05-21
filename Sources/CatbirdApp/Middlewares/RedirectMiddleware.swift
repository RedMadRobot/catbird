import Vapor

final class RedirectMiddleware: Middleware {

    private let serverURL: URL

    init(serverURL: URL) {
        self.serverURL = serverURL
    }

    // MARK: - Middleware

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // TODO: request.http.urlString = baseURL.absoluteString + request.http.urlString

        let clientRequest = ClientRequest(
            method: request.method,
            url: request.url,
            headers: request.headers,
            body: request.body.data)

        return request
            .client
            .send(clientRequest)
            .map { (response: ClientResponse) -> Response in
                let body = response.body.map { Response.Body(buffer: $0) } ?? .empty
                return Response(
                    status: response.status,
                    version: request.version,
                    headers: response.headers,
                    body: body)
            }
    }
}
