import CatbirdAPI
import HTTP

extension RequestPattern {

    init(httpRequest: HTTPRequest) {
        var headers: [String: String] = [:]
        httpRequest.headers.forEach { headers[$0.name] = $0.value }

        self.init(
            method: httpRequest.method.string,
            url: httpRequest.url,
            headerFields: headers)
    }

    func match(_ httpRequest: HTTPRequest) -> Bool {
        // TODO: check headers

        return httpRequest.method.string == method
            && httpRequest.url == url
    }
}
