import CatbirdAPI
import Vapor

//final class FileResponseStore: ResponseStore {
//
//    /// The directory for response files.
//    private let path: String
//
//    private let fileManager: FileManager
//
//    init(path: String, fileManager: FileManager = .default) {
//        self.path = path
//        self.fileManager = fileManager
//    }
//
//    // MARK: - ResponseStore
//
//    func response(for request: Request) throws -> Response {
//        let url = URL(fileURLWithPath: path + request.http.url.path, isDirectory: false)
//        let data = try Data(contentsOf: url)
//        return request.response(data)
//    }
//
//    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
//        guard let body = data?.body else { return }
//        
//        let patternPath: String
//        if case .equal = pattern.url.kind, let url = URL(string: pattern.url.value) {
//            patternPath = url.path
//        } else {
//            patternPath = pattern.url.value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
//        }
//        let url = URL(fileURLWithPath: path + patternPath, isDirectory: false)
//        try createDirectories(for: url)
//        try body.write(to: url)
//    }
//
//    func removeAllResponses() throws {}
//
//    // MARK: - Private
//
//    private func createDirectories(for url: URL) throws {
//        // Remove file name
//        let dirUrl = url.deletingLastPathComponent()
//        try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true)
//    }
//}

final class FileResponseStore: ResponseStore {
    /// Path to the response body folder.
    private let directory: URL

    private let fileManger = FileManager.default

    init(directory: URL) {
        self.directory = directory
    }

    // MARK: - ResponseStore

    var items: [ResponseStoreItem] { [] }

    func response(for request: Request) -> EventLoopFuture<Response> {
        let path = self.path(request)
        guard fileManger.fileExists(atPath: path) else {
            return request.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        let response = request.fileio.streamFile(at: path)
        return request.eventLoop.makeSucceededFuture(response)
    }

    func perform(_ action: CatbirdAction, for request: Request) -> EventLoopFuture<Response> {
        guard case .update(_, let response?) = action else {
            return request.eventLoop.makeSucceededFuture(Response(status: .forbidden))
        }
        return request.eventLoop.makeSucceededFuture(Response(status: .notImplemented))
    }

    // MARK: - Private

    private func path(_ request: Request) -> String {
        return directory.absoluteString + request.url.path
    }

    private func createDirectories(_ url: URL) throws {
        // Remove file name
        let dirUrl = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: dirUrl,
            withIntermediateDirectories: true)
    }
}
