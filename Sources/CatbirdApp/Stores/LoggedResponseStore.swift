import CatbirdAPI
import Vapor

final class LoggedResponseStore: ResponseStore {
    private let store: ResponseStore
    private let logger: Logger

    init(store: ResponseStore, logger: Logger) {
        self.store = store
        self.logger = logger
    }

    // MARK: - ResponseStore

    var items: [ResponseStoreItem] { store.items }

    func response(for request: Request) -> EventLoopFuture<Response> {
        logger.info("\(request.method) \(request.url)")
        return store.response(for: request)
    }

    func perform(_ action: CatbirdAction, for request: Request) -> EventLoopFuture<Response> {
        switch action {
        case .update(let pattern, .some):
            logger.info("write at url: \(pattern.url.value)")
        case .update(let pattern, .none):
            logger.info("remove at url: \(pattern.url.value)")
        case .removeAll:
            logger.info("remove all responses")
        }
        return store.perform(action, for: request)
    }

}

