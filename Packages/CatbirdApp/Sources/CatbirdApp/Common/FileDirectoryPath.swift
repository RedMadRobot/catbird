import Foundation
import Vapor

struct FileDirectoryPath {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func preferredFileURL(for request: Request) -> URL {
        var fileUrl = fileURL(for: request)

        guard fileUrl.pathExtension.isEmpty else {
            return fileUrl
        }
        if let filenameExtension = request.accept.first?.preferredFilenameExtension {
            fileUrl.appendPathExtension(filenameExtension)
        }
        return fileUrl
    }

    func filePaths(for request: Request) -> [String] {
        let fileUrl = fileURL(for: request)

        var urls: [URL] = []
        if fileUrl.pathExtension.isEmpty {
            urls = request.accept
                .compactMap { $0.preferredFilenameExtension }
                .map { fileUrl.appendingPathExtension($0) }
        }
        urls.append(fileUrl)
        return urls.map { $0.absoluteString }
    }

    private func fileURL(for request: Request) -> URL {
        var fileUrl = url
        if let host = request.url.host {
            fileUrl.appendPathComponent(host)
        }
        fileUrl.appendPathComponent(request.url.path)
        if fileUrl.absoluteString.hasSuffix("/") {
            fileUrl.appendPathComponent("index")
        }
        return fileUrl
    }
}
