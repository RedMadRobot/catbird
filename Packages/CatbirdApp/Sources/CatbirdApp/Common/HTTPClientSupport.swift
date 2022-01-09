import Vapor

extension Request {
    /// Send HTTP request.
    ///
    /// - Parameter configure: client request configuration function.
    /// - Returns: Server response.
    func send(configure: ((inout ClientRequest) -> Void)? = nil) -> EventLoopFuture<Response> {
        return body
            .collect(max: nil)
            .flatMap { (bytesBuffer: ByteBuffer?) -> EventLoopFuture<Response> in
                var clientRequest = self.clientRequest(body: bytesBuffer)
                configure?(&clientRequest)
                return self.client.send(clientRequest).map { (clientResponse: ClientResponse) -> Response in
                    clientResponse.response(version: self.version)
                }
            }
    }

    /// Convert to HTTP client request.
    private func clientRequest(body: ByteBuffer?) -> ClientRequest {
        var headers = self.headers
        if let host = headers.first(name: "Host") {
            headers.replaceOrAdd(name: "X-Forwarded-Host", value: host)
            headers.remove(name: "Host")
        }
        return ClientRequest(method: method, url: url, headers: headers, body: body)
    }
}

extension HTTPHeaders {
    fileprivate var contentLength: Int? {
        first(name: "Content-Length").flatMap { Int($0) }
    }
}

extension ClientResponse {
    /// Convert to Server Response.
    fileprivate func response(version: HTTPVersion) -> Response {
        let body = body.map { Response.Body(buffer: $0) } ?? .empty
        return Response(status: status, version: version, headers: headers, body: body)
    }
}
