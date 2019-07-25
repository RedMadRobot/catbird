import CatbirdAPI
import Vapor

final class DataResponseStore: ResponseStore, BagsResponseStore {

    private(set) var bags: [RequestBag] = []

    // MARK: - ResponseStore

    func response(for request: Request) throws -> Response {
        for bag in bags {
            if bag.pattern.match(request.http) {
                return request.response(http: bag.data.httpResponse)
            }
        }
        throw Abort(.notFound)
    }

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
        guard let data = data else { 
            bags.removeAll { $0.pattern == pattern }
            return
        }
        let bag = RequestBag(pattern: pattern, data: data)
        if !bags.contains(bag) {
            bags.append(bag)
        }
    }

    func removeAllResponses() throws {
        bags.removeAll(keepingCapacity: true)
    }

}
