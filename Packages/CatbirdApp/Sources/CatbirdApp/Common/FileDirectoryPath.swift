import Foundation
import Vapor

struct FileDirectoryPath {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    init(_ path: String) {
        self.url = URL(fileURLWithPath: path, isDirectory: true)
    }

    func preferredFileURL(for request: Request) -> URL {
        var url = self.url.appendingPathComponent(request.url.string)

        guard url.pathExtension.isEmpty else {
            return url
        }
        if let filenameExtension = request.accept.first?.preferredFilenameExtension {
            url.appendPathExtension(filenameExtension)
        }
        return url
    }

    func fileURLs(for request: Request) -> [URL] {
        let url = self.url.appendingPathComponent(request.url.string)

        guard url.pathExtension.isEmpty else {
            return [url]
        }

        var urls: [URL] = request.accept
            .compactMap { $0.preferredFilenameExtension }
            .map { url.appendingPathExtension($0) }

        urls.append(url)
        return urls
    }
}
