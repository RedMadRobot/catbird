import CatbirdAPI
import Vapor
import NIOSSL

public struct CatbirdInfo: Content {
    public static let current = CatbirdInfo(
        version: "0.10.0",
        domain: "com.redmadrobot.catbird",
        github: "https://github.com/redmadrobot/catbird/")

    public let version: String
    public let domain: String
    public let github: String
}

public func configure(_ app: Application, _ configuration: AppConfiguration) throws {
    app.routes.defaultMaxBodySize = ByteCount(stringLiteral: configuration.maxBodySize)
    let info = CatbirdInfo.current

    // MARK: - Stores

    // Store for static mocks on disk
    let fileStore: ResponseStore = LoggedResponseStore(
        store: FileResponseStore(directory: configuration.mocksDirectory),
        logger: Loggers.fileStore)

    // Store for dynamic mocks in memory
    let inMemoryStore: ResponseStore = LoggedResponseStore(
        store: InMemoryResponseStore(),
        logger: Loggers.inMemoryStore)

    // MARK: - Register Middleware

    // Pubic resource for web page
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if configuration.isRecordMode {
        app.logger.info("Record mode")
        app.http.client.configuration.decompression = .enabled(limit: .none)
        // capture response and write to file
        app.middleware.use(AnyMiddleware.capture { request, response in
            if response.headers.contains(name: "Content-encoding") {
                response.headers.remove(name: "Content-encoding")
            }
            let pattern = RequestPattern(method: .init(request.method.rawValue), url: request.url.string)
            let mock = ResponseMock(status: Int(response.status.code), body: response.body.data)
            return fileStore.perform(.update(pattern, mock), for: request).map { _ in response }
        })
    } else {
        app.logger.info("Read mode")
        // try read from static mocks if route not found
        app.middleware.use(AnyMiddleware.notFound(fileStore.response))
        // try read from dynamic mocks
        app.middleware.use(AnyMiddleware.notFound(inMemoryStore.response))
    }
    if let url = configuration.redirectUrl {
        app.middleware.use(RedirectMiddleware(serverURL: url))
    }
    if configuration.proxyEnabled {
        app.middleware.use(ProxyMiddleware())
    }

    // MARK: - Register Routes

    let render = HTMLRender(
        viewsDirectroy: app.directory.viewsDirectory,
        allocator: app.allocator)

    app.group("catbird") { catbird in
        catbird.get("version") { _ in "Version: \(info.version)" }
        catbird.get("github") { $0.redirect(to: info.github) }
        catbird.get { request in
            try render.render("index.html", ["page": PageViewModel(items: inMemoryStore.items)])
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
