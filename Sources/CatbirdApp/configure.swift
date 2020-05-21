import CatbirdAPI
import Vapor
import OSLogging
import Leaf

public struct CatbirdInfo: Content {
    public static let current = CatbirdInfo()

    public let version = "1.2.0"
    public let domain = "com.redmadrobot.catbird"
    public let github = "https://github.com/redmadrobot/catbird/"
}

public func configure(_ app: Application, _ configuration: AppConfiguration) throws {
    let info = CatbirdInfo.current

    app.views.use(.leaf)
    app.leaf.cache.isEnabled = false

    // MARK: - Stores

    // Store for static mocks on disk
    let fileStore: ResponseStore = LoggedResponseStore(
        store: FileResponseStore(directory: configuration.mocksDirectory),
        logger: Logger(label: info.domain) {
            OSLogHandler(subsystem: $0, category: "File")
        })

    // Store for dynamic mocks in memory
    let inMemoryStore: ResponseStore = LoggedResponseStore(
        store: InMemoryResponseStore(),
        logger: Logger(label: info.domain) {
            OSLogHandler(subsystem: $0, category: "InMemory")
        })

    // MARK: - Register Middlewares

    // Pubic resource for web page
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    switch configuration.mode {
    case .read:
        app.logger.info("Read mode")
        // try read from static mocks if route not found
        app.middleware.use(AnyMiddleware.notFound { fileStore.response(for: $0) })
        // try read from dynamic mocks
        app.middleware.use(AnyMiddleware.notFound { inMemoryStore.response(for: $0) })
    case .write(let url):
        app.logger.info("Write mode")
        // redirect request to another server
        app.middleware.use(RedirectMiddleware(serverURL: url))
        // capture response and write to file
        app.middleware.use(AnyMiddleware.capture { request, response in
            let pattern = RequestPattern(method: .init(request.method.rawValue), url: request.url.string)
            let mock = ResponseMock(status: Int(response.status.code), body: response.body.data)
            return fileStore.perform(.update(pattern, mock), for: request)
        })
    }

    // MARK: - Register Routes

    app.group("catbird") { catbird in
        catbird.get("version") { _ in "Version: \(info.version)" }
        catbird.get("github") { $0.redirect(to: info.github) }
        catbird.get { request in
            request.view.render("index", PageViewModel(items: inMemoryStore.items))
        }
        catbird.group("api") { api in
            api.get("info") { _ in info }
            api.group("mocks") { mocks in
                mocks.post { (request: Request) -> EventLoopFuture<Response> in
                    let action = try request.content.decode(CatbirdAction.self)
                    return inMemoryStore.perform(action, for: request)
                }
            }
        }
    }
}

/// Called before your application initializes.
//public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
//    // Register logger
//    let logger = SystemLogger.default
//    services.register(logger, as: Logger.self)
//    config.prefer(SystemLogger.self, for: Logger.self)
//
//    let appConfig = try AppConfiguration.detect()
//
//    let fileStore = LogResponseStore(
//        store: FileResponseStore(path: appConfig.mocksDirectory),
//        logger: SystemLogger.category("File"))
//
//    let dataResponseStore = DataResponseStore()
//    let dataStore = LogResponseStore(
//        store: dataResponseStore,
//        logger: SystemLogger.category("Data"))
//
//    // Register routes to the router
//    let router = EngineRouter.default()
//    try routes(router)
//    let apiController = APIController(store: dataStore)
//    try router.register(collection: apiController)
//    let webController = WebController(store: dataResponseStore)
//    try router.register(collection: webController)
//    services.register(router, as: Router.self)
//
//    // Register middleware
//    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
//    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
//    middlewares.use(FileMiddleware.self) // Serves static files from a public directory.
//
//    switch appConfig.mode {
//    case .write(let url):
//        services.register { ProxyMiddleware(baseURL: url, logger: try $0.make()) }
//        middlewares.use(ResponseWriterMiddleware(store: fileStore))
//        middlewares.use(ProxyMiddleware.self)
//        logger.info("Write mode")
//    case .read:
//        middlewares.use(ResponseReaderMiddleware(store: fileStore))
//        middlewares.use(ResponseReaderMiddleware(store: dataStore))
//        logger.info("Read mode")
//    }
//
//    services.register(middlewares)
//
//    // Register view renderer
//    let leafProvider = LeafProvider()
//    try services.register(leafProvider)
//    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
//}
