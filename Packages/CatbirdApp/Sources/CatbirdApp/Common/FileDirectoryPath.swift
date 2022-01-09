import Foundation
import Vapor

struct FileDirectoryPath {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func preferredFileURL(for request: Request) -> URL {
        var fileUrl = url.appendingPathComponent(request.url.string)

        guard fileUrl.pathExtension.isEmpty else {
            return fileUrl
        }
        if let filenameExtension = request.accept.first?.preferredFilenameExtension {
            fileUrl.appendPathExtension(filenameExtension)
        }
        return fileUrl
    }

    func filePaths(for request: Request) -> [String] {
        let fileUrl = url.appendingPathComponent(request.url.string)

        var urls: [URL] = []
        if fileUrl.pathExtension.isEmpty {
            urls = request.accept
                .compactMap { $0.preferredFilenameExtension }
                .map { fileUrl.appendingPathExtension($0) }
        }
        urls.append(fileUrl)
        return urls.map { $0.absoluteString }
    }
}
