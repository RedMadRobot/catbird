import CatbirdAPI
import Vapor

struct ResponseStoreItem: Equatable {
    let pattern: RequestPattern
    private(set) var mock: ResponseMock
}

extension ResponseStoreItem {

    var isValid: Bool {
        mock.limit.map { $0 > 0 } ?? true
    }

    /// Make HTTP response from mock.
    var response: Response {
        let status = HTTPResponseStatus(statusCode: mock.status)
        var headers = HTTPHeaders()
        mock.headers.forEach { headers.add(name: $0.key, value: $0.value) }
        let body = mock.body.map { Response.Body(data: $0) } ?? .empty
        return Response(status: status, headers: headers, body: body)
    }

    mutating func decremented() -> ResponseStoreItem {
        if let limit = mock.limit {
            mock.limit = limit - 1
        }
        return self
    }

    func match(_ request: Request) -> Bool {
        pattern.method.rawValue == request.method.string
            && pattern.url.match(request.url.string)
            && pattern.headers.allSatisfy { key, pattern in
                request.headers.first(name: key).map(pattern.match) ?? false
            }
    }

}
