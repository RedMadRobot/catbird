import CatbirdAPI
import Vapor
import NIO

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
        let path = filePath(for: request)
        guard fileManger.fileExists(atPath: path) else {
            return request.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        let response = request.fileio.streamFile(at: path)
        return request.eventLoop.makeSucceededFuture(response)
    }

    func perform(_ action: CatbirdAction, for request: Request) -> EventLoopFuture<Response> {
        let eventLoop = request.eventLoop
        guard case .update(_, let response?) = action, let body = response.body, !body.isEmpty else {
            return eventLoop.makeSucceededFuture(Response(status: .badRequest))
        }
        let path = filePath(for: request)
        do {
            try createDirectories(for: path)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
        return writeFile(data: body, at: path, request: request)
            .map { _ in Response(status: .created) }
    }

    // MARK: - Private

    private func filePath(for request: Request) -> String {
        return directory.absoluteString + request.url.path
    }

    private func createDirectories(for filePath: String) throws {
        let url = URL(fileURLWithPath: filePath, isDirectory: false)
        // Remove file name
        let dir = url.deletingLastPathComponent()
        try fileManger.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    private func writeFile(data: Data, at path: String, request: Request) -> EventLoopFuture<Void> {
        let fileio = request.application.fileio
        let eventLoop = request.eventLoop
        return fileio
            .openFile(path: path, mode: .write, flags: .allowFileCreation(), eventLoop: eventLoop)
            .flatMap { (fileHandle: NIOFileHandle) -> EventLoopFuture<Void> in
                var buffer = request.application.allocator.buffer(capacity: data.count)
                buffer.writeBytes(data)
                return fileio
                    .write(fileHandle: fileHandle, buffer: buffer, eventLoop: eventLoop)
                    .always { _ in try! fileHandle.close() }
            }
    }
}