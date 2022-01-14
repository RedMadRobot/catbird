import Vapor
import Foundation

#if canImport(CoreServices)
import CoreServices
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

struct MIMEType: Equatable {
    private let string: String

    init(_ string: String) {
        self.string = string
    }

    var preferredFilenameExtension: String? {
#if os(Linux)
        return _UTType(mimeType: string)?.preferredFilenameExtension
#else
        if #available(macOS 11.0, *) {
            return UTType(mimeType: string)?.preferredFilenameExtension
        } else {
            return _UTType(mimeType: string)?.preferredFilenameExtension
        }
#endif
    }
}

extension Vapor.Request {
    var accept: [MIMEType] {
        headers[canonicalForm: "Accept"].map { MIMEType(String($0)) }
    }
}

#if os(Linux)
private struct _UTType {

    var preferredFilenameExtension: String? {
        return nil
    }

    init?(mimeType: String) {
        return nil
    }
}
#else
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
#endif
