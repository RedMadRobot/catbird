import CatbirdAPI
@testable import CatbirdApp
import Vapor

final class ResponseStoreMock: ResponseStore {

    // `Request` and `Response` are not `Equtalbe`.
    private var responses: [ObjectIdentifier: Response] = [:]

    var isEmpry: Bool { return responses.isEmpty }

    subscript(request: Request) -> Response? {
        get {
            return responses[ObjectIdentifier(request)]
        }
        set(response) {
            responses[ObjectIdentifier(request)] = response
        }
    }

    // MARK: - ResponseStore

    func response(for request: Request) throws -> Response {
        guard let response = self[request] else {
            throw Abort(.notFound)
        }
        return response
    }

    func setResponse(_ response: Response, for request: Request) throws {
        self[request] = response
    }

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
        fatalError()
    }

    func removeAllResponses(for request: Request) throws {
        responses.removeAll()
    }
}
