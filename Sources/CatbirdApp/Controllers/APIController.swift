import CatbirdAPI
import Vapor

/// Controls basic CRUD operations on `Mock`s.
final class APIController: RouteCollection {

    private let store: ResponseStore

    init(store: ResponseStore) {
        self.store = store
    }

    // MARK: - RouteCollection

    func boot(router: Router) throws {
        let group = router.grouped("catbird", "api")

        group.post(RequestBag.self, use: create)
        group.delete(use: delete)
        group.delete("clear", use: clear)
    }

    // MARK: - Action

    func create(_ request: Request, bag: RequestBag) throws -> HTTPStatus {
        var pattern = bag.pattern
        let header = Catbird.sessionId
        pattern.headerFields[header] = request.http.headers[header].first.map(Pattern.equal)
        try store.setResponse(data: bag.data, for: pattern)
        return HTTPStatus.created
    }

    func delete(_ request: Request) throws -> Future<HTTPStatus> {
        return try request
            .content.decode(RequestPattern.self)
            .map(to: HTTPStatus.self) { [store] pattern in
                try store.setResponse(data: nil, for: pattern)
                return HTTPStatus.noContent
            }
    }

    func clear(_ request: Request) throws -> HTTPStatus {
        try store.removeAllResponses()
        return HTTPStatus.noContent
    }

}

// for post route
extension RequestBag: Content {}
