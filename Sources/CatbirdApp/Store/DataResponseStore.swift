import CatbirdAPI
import Vapor

final class DataResponseStore: ResponseStore, BagsResponseStore {

    private(set) var bags: [RequestPattern : ResponseData] = [:]

    // MARK: - ResponseStore

    func response(for request: Request) throws -> Response {
        for (pattern, response) in bags {
            if pattern.match(request.http) {
                return request.response(http: response.httpResponse)
            }
        }
        throw Abort(.notFound)
    }

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
        guard let data = data else { return }
        bags[pattern] = data
    }

    func removeAllResponses() throws {
        bags.removeAll(keepingCapacity: true)
    }

}
