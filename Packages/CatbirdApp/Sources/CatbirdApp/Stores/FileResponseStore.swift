import Foundation
import CatbirdAPI
import Vapor
import NIO

final class FileResponseStore: ResponseStore {
    /// Path to the response body folder.
    private let directory: FileDirectoryPath

    private let fileManger = FileManager.default

    init(directory: URL) {
        self.directory = FileDirectoryPath(url: directory)
    }

    // MARK: - ResponseStore

    var items: [ResponseStoreItem] { [] }

    func response(for request: Request) -> EventLoopFuture<Response> {
        guard let path = directory.filePaths(for: request).first(where: {
            fileExists(atPath: $0)
        }) else {
            return request.eventLoop.makeFailedFuture(Abort(.notFound))
        }
        let response = request.fileio.streamFile(at: path)
        return request.eventLoop.makeSucceededFuture(response)
    }

    func perform(_ action: CatbirdAction, for request: Request) -> EventLoopFuture<Response> {
        let eventLoop = request.eventLoop
        guard case .update(_, let response) = action, let body = response.body, !body.isEmpty else {
            return eventLoop.makeSucceededFuture(Response(status: .badRequest))
        }
        let url = directory.preferredFileURL(for: request)
        do {
            try createDirectories(for: url)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
        return writeFile(data: body, at: url.absoluteString, request: request)
            .map { _ in Response(status: .created) }
    }

    // MARK: - Private

    private func fileExists(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManger.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue
    }

    private func createDirectories(for fileUrl: URL) throws {
        assert(!fileUrl.hasDirectoryPath)
        // Remove file name
        let path = fileUrl.deletingLastPathComponent().absoluteString
        let url = URL(fileURLWithPath: path, isDirectory: true)
        try fileManger.createDirectory(at: url, withIntermediateDirectories: true)
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
