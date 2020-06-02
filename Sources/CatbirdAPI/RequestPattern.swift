import Foundation

/// The matching pattern of the request to the server.
///
/// The intercepted request must return `ResponseData`.
public struct RequestPattern: Codable, Hashable {

    /// HTTP method.
    public var method: HTTPMethod

    /// Request URL.
    public var url: Pattern

    /// Request required headers.
    public var headers: [String: Pattern]

    /// A new request pattern.
    ///
    /// - Parameters:
    ///   - method: HTTP method.
    ///   - url: Request URL or pattern.
    ///   - headers: Request required headers.
    public init(
        method: HTTPMethod,
        url: PatternRepresentable,
        headers: [String: PatternRepresentable] = [:]) {

        self.method = method
        self.url = url.pattern
        self.headers = headers.mapValues { $0.pattern }
    }

}

// MARK: - HTTPMethod

extension RequestPattern {
    public struct HTTPMethod: RawRepresentable, Hashable, Codable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let GET = HTTPMethod("GET")
        public static let POST = HTTPMethod("POST")
        public static let PUT = HTTPMethod("PUT")
        public static let PATCH = HTTPMethod("PATCH")
        public static let DELETE = HTTPMethod("DELETE")
    }
}

extension RequestPattern.HTTPMethod: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension RequestPattern.HTTPMethod: LosslessStringConvertible {
    public var description: String { rawValue }

    public init(_ description: String) {
        self.rawValue = description
    }
}
