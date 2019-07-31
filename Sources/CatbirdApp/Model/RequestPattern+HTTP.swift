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
        var result = httpRequest.method.string == method
        result = result && url.match(httpRequest.url.absoluteString)
        for patternHeader in headerFields {
            // We not support multiple headers with the same key
            if let value = httpRequest.headers[patternHeader.key].first {
                result = result && patternHeader.value.match(value)
            } else {
                return false
            }
        }
        return result
    }
}
