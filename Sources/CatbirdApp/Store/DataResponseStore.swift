import CatbirdAPI
import Vapor

final class DataResponseStore: ResponseStore, BagsResponseStore {

    private(set) var bags: [RequestBag] = []

    // MARK: - ResponseStore

    func response(for request: Request) throws -> Response {
        for bag in bags where bag.pattern.match(request.http) {
            return request.response(http: bag.data.httpResponse)
        }
        throw Abort(.notFound)
    }

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
        guard let data = data else { 
            bags.removeAll { $0.pattern == pattern }
            return
        }
        let bag = RequestBag(pattern: pattern, data: data)
        if let index = bags.firstIndex(where: { $0.pattern == pattern }) {
            bags[index] = bag
        } else {
            bags.append(bag)
        }
    }

    func removeAllResponses(for request: Request) throws {
        if let session = request.http.headers[Catbird.sessionId].first {
            bags.removeAll { $0.pattern.headerFields[Catbird.sessionId]?.value == session }
        } else {
            bags.removeAll(keepingCapacity: true)
        }
    }

}
