import Vapor
import Foundation
import CoreServices
import UniformTypeIdentifiers

struct MIMEType: Equatable {
    private let string: String

    init(_ string: String) {
        self.string = string
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
