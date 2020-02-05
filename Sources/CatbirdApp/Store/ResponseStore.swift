import CatbirdAPI
import Vapor

typealias ResponseStore = ResponseReader & ResponseWriter

protocol ResponseReader {

    func response(for request: Request) throws -> Response
}

protocol ResponseWriter {

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws

    func removeAllResponses(for request: Request) throws
}

extension ResponseWriter {

    func setResponse(_ response: Response, for request: Request) throws {
        let pattern = RequestPattern(httpRequest: request.http)
        let data = ResponseData(httpResponse: response.http)
        try setResponse(data: data, for: pattern)
    }
}
