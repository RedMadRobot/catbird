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
//    app.logger.logLevel = .trace
    let info = CatbirdInfo.current

    // /Users/alexander.ignatiev/Documents/Notes/podlodka/hacker_news/server/go/cert/server.crt
    // /Users/alexander.ignatiev/Documents/Notes/podlodka/hacker_news/server/go/cert/server.key

/*

 CATBIRD_CERT_PATH
 CATBIRD_KEY_PATH

 */
    
//    try app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
//        certificateChain: NIOSSLCertificate.fromPEMFile("/Users/alexander.ignatiev/GitHub/catbird/cert.pem").map { .certificate($0) },
//        privateKey: .file("/Users/alexander.ignatiev/GitHub/catbird/cert.key")
//    )
//    app.http.server.configuration.supportVersions = [.one]

//    try app.http.server.configuration.tlsConfiguration = .makeServerConfiguration(
//        certificateChain: NIOSSLCertificate.fromPEMFile("/Users/alexander.ignatiev/Developer/proxyman/proxyman-cert.pem").map { .certificate($0) },
//        privateKey: .file("/Users/alexander.ignatiev/Developer/proxyman/proxyman-key.pem")
//    )

    app.http.server.configuration.tlsConfiguration

//    let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
//        certificateChain: try NIOSSLCertificate.fromPEMFile("/Users/alexander.ignatiev/GitHub/catbird/cert.pem").map { .certificate($0) },
//        privateKey: .file("/Users/alexander.ignatiev/GitHub/catbird/cert.key"))
//
//    let ssl = try NIOSSLContext(configuration: tlsConfiguration)

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

    let httpTunnel = AnyMiddleware { request, next in
        guard request.method == .CONNECT else {
            return next.respond(to: request)
        }
        request.logger.info("http tunnel \(request.headers)")
//        let response = Response(status: .movedPermanently, headers: ["Location": "http://ya.ru"])
        let response = Response(status: .ok, body: .init(stream: { writer in
            writer.write(.buffer(ByteBuffer.init(integer: 5)))
        }, count: 1))
        return request.eventLoop.makeSucceededFuture(response)
    }
    app.middleware.use(httpTunnel)

    // Pubic resource for web page
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    switch configuration.mode {
    case .read:
        app.logger.info("Read mode")
//        app.middleware.use(AnyMiddleware.notFound({ request in
//            request.eventLoop.makeSucceededFuture(Response(status: .imATeapot, version: request.version))
//        }))
        // try read from static mocks if route not found
        app.middleware.use(AnyMiddleware.notFound(fileStore.response))
        // try read from dynamic mocks
        app.middleware.use(AnyMiddleware.notFound(inMemoryStore.response))
    case .write(let url):
        app.logger.info("Write mode")
        // capture response and write to file
        app.middleware.use(AnyMiddleware.capture { request, response in
            let pattern = RequestPattern(method: .init(request.method.rawValue), url: request.url.string)
            let mock = ResponseMock(status: Int(response.status.code), body: response.body.data)
            return fileStore.perform(.update(pattern, mock), for: request).map { _ in response }
        })
        // redirect request to another server
        app.middleware.use(RedirectMiddleware(serverURL: url))
    }
//    app.middleware.use(ProxyMiddleware())

//    let config = Config()
//
//    if config.recordingMode {
//        app.middleware.use(RecordingMiddleware(store: fileStore))
//    } else {
//        // try read from static mocks if route not found
//        app.middleware.use(AnyMiddleware.notFound(fileStore.response))
//        // try read from dynamic mocks
//        app.middleware.use(AnyMiddleware.notFound(inMemoryStore.response))
//    }
//    if let url = config.redirectUrl {
//        app.middleware.use(RedirectMiddleware(serverURL: url))
//    }
//    if config.proxyEnabled {
//        app.middleware.use(ProxyMiddleware())
//    }

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
