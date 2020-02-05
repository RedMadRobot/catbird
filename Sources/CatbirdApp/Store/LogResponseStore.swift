import CatbirdAPI
import Vapor

final class LogResponseStore: ResponseStore {

    private let store: ResponseStore
    private let logger: Logger

    init(store: ResponseStore, logger: Logger) {
        self.store = store
        self.logger = logger
    }

    // MARK: - ResponseStore

    func response(for request: Request) throws -> Response {
        logger.debug("read at url: \(request.http.urlString)")
        return try store.response(for: request)
    }

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
        logger.debug("write at url: \(pattern.url)")
        try store.setResponse(data: data, for: pattern)
    }

    func removeAllResponses(for request: Request) throws {
        logger.debug("remove all responses")
        try store.removeAllResponses(for: request)
    }

}
