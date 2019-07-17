import CatbirdAPI
import Vapor

final class DataResponseStore: ResponseStore, BagsResponseStore {

    private(set) var bags: [RequestPattern : ResponseData] = [:]

    // MARK: - ResponseStore

    func response(for request: Request) throws -> Response {
        let pattern = RequestPattern(method: request.http.method.string,
                                     url: request.http.url,
                                     headerFields: [:])
        guard let response = bags[pattern] else { throw Abort(.notFound) }
        return request.response(http: response.httpResponse)
    }

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
        guard let data = data else { return }
        bags[pattern] = data
    }

    func removeAllResponses() throws {
        bags.removeAll(keepingCapacity: true)
    }

}
