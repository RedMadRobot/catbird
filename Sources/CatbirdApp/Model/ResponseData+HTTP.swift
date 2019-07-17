import CatbirdAPI
import HTTP

extension ResponseData {

    var httpResponse: HTTPResponse {
        return HTTPResponse(
            status: HTTPResponseStatus(statusCode: statusCode),
            headers: HTTPHeaders(headerFields.map { $0 }),
            body: body ?? HTTPBody.empty)
    }

    init(httpResponse: HTTPResponse) {
        var headers: [String: String] = [:]
        httpResponse.headers.forEach { headers[$0.name] = $0.value }

        self.init(
            statusCode: Int(httpResponse.status.code),
            headerFields: headers,
            body: httpResponse.body.data)
    }
}
