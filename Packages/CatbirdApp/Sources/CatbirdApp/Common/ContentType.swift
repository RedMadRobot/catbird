import Foundation
import CoreServices
import UniformTypeIdentifiers

struct ContentType {
    private enum Base {
        case filenameExtension(String)
        case mimeType(String)
    }

    private let base: Base

    init(filenameExtension: String) {
        self.base = .filenameExtension(filenameExtension)
    }

    init(mimeType: String) {
        self.base = .mimeType(mimeType)
    }

    var preferredMIMEType: String? {
        switch base {
        case .filenameExtension(let string):
            if #available(macOS 11.0, *) {
                return UTType(filenameExtension: string)?.preferredMIMEType
            } else {
                return _UTType(filenameExtension: string)?.preferredMIMEType
            }
        case .mimeType(let string):
            return string
        }
    }

    var preferredFilenameExtension: String? {
        switch base {
        case .filenameExtension(let string):
            return string
        case .mimeType(let string):
            if #available(macOS 11.0, *) {
                return UTType(mimeType: string)?.preferredFilenameExtension
            } else {
                return _UTType(mimeType: string)?.preferredFilenameExtension
            }
        }
    }
}

private struct _UTType {
    private let identifier: CFString

    var preferredMIMEType: String? {
        self.preferredTag(with: kUTTagClassMIMEType)
    }

    var preferredFilenameExtension: String? {
        self.preferredTag(with: kUTTagClassFilenameExtension)
    }

    init?(mimeType: String) {
        self.init(tagClass: kUTTagClassMIMEType, tag: mimeType)
    }

    init?(filenameExtension: String) {
        self.init(tagClass: kUTTagClassFilenameExtension, tag: filenameExtension)
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
