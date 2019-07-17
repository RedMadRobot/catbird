import Leaf
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register logger
    let logger = SystemLogger.default
    services.register(logger, as: Logger.self)
    config.prefer(SystemLogger.self, for: Logger.self)

    let appConfig = try AppConfig.detect()
    
    let fileStore = LogResponseStore(
        store: FileResponseStore(path: appConfig.mocksDirectory),
        logger: SystemLogger.category("File"))

    let dataResponseStore = DataResponseStore()
    let dataStore = LogResponseStore(
        store: dataResponseStore,
        logger: SystemLogger.category("Data"))

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    let apiController = APIController(store: dataStore)
    try router.register(collection: apiController)
    let webController = WebController(store: dataResponseStore)
    try router.register(collection: webController)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(FileMiddleware.self) // Serves static files from a public directory.

    switch appConfig.mode {
    case .write(let url):
        services.register { ProxyMiddleware(baseURL: url, logger: try $0.make()) }
        middlewares.use(ResponseWriterMiddleware(store: fileStore))
        middlewares.use(ProxyMiddleware.self)
        logger.info("Write mode")
    case .read:
        middlewares.use(ResponseReaderMiddleware(store: fileStore))
        middlewares.use(ResponseReaderMiddleware(store: dataStore))
        logger.info("Read mode")
    }

    services.register(middlewares)
    
    // Register view renderer
    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
