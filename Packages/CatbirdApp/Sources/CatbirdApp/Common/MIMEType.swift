import Vapor
import Foundation
import CoreServices
import UniformTypeIdentifiers

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

struct MIMEType: LosslessStringConvertible, Equatable {
    let string: String

    init(_ string: String) {
        self.string = string
    }

    var description: String {
        "MIMEType(\(string))"
    }

    var preferredFilenameExtension: String? {
        if #available(macOS 11.0, *) {
            return UTType(mimeType: string)?.preferredFilenameExtension
        } else {
            return _UTType(mimeType: string)?.preferredFilenameExtension
        }
    }
}

extension Vapor.Request {
    var accept: [MIMEType] {
        headers[canonicalForm: "Accept"].map { MIMEType(String($0)) }
    }
}

private struct _UTType {
    private let identifier: CFString

    var preferredFilenameExtension: String? {
        self.preferredTag(with: kUTTagClassFilenameExtension)
    }

    init?(mimeType: String) {
        self.init(tagClass: kUTTagClassMIMEType, tag: mimeType)
    }

    private init?(tagClass: CFString, tag: String) {
        guard let identifier = UTTypeCreatePreferredIdentifierForTag(tagClass, tag as CFString, nil) else {
            return nil
        }
        self.identifier = identifier.takeRetainedValue()
    }

    private func preferredTag(with tagClass: CFString) -> String? {
        UTTypeCopyPreferredTagWithClass(identifier, tagClass)?.takeRetainedValue() as String?
    }
}
