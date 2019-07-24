import Foundation

/// The matching pattern of the request to the server.
///
/// The intercepted request must return `ResponseData`.
public struct RequestPattern: Codable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url.value)
        hasher.combine(method)
        hasher.combine(headerFields)
    }
    
    /// HTTP method.
    public let method: String

    /// Request URL.
    public let url: Pattern

    /// Request required headers. Default empty.
    public let headerFields: [String: Pattern]

    /// A new request pattern.
    ///
    /// - Parameters:
    ///   - method: HTTP method.
    ///   - url: Request URL.
    ///   - headerFields: Request required headers. Default empty.
    public init(method: String, url: PatternRepresentable, headerFields: [String: PatternRepresentable] = [:]) {
        self.method = method
        self.url = url.pattern
        self.headerFields = headerFields.mapValues { $0.pattern }
    }

    /// A new pattern for `GET` request.
    public static func get(_ url: PatternRepresentable, headerFields: [String: PatternRepresentable] = [:]) -> RequestPattern {
        return RequestPattern(method: "GET", url: url, headerFields: headerFields)
    }

    /// A new pattern for `POST` request.
    public static func post(_ url: PatternRepresentable, headerFields: [String: PatternRepresentable] = [:]) -> RequestPattern {
        return RequestPattern(method: "POST", url: url, headerFields: headerFields)
    }

    /// A new pattern for `PUT` request.
    public static func put(_ url: PatternRepresentable, headerFields: [String: PatternRepresentable] = [:]) -> RequestPattern {
        return RequestPattern(method: "PUT", url: url, headerFields: headerFields)
    }

    /// A new pattern for `PATCH` request.
    public static func patch(_ url: PatternRepresentable, headerFields: [String: PatternRepresentable] = [:]) -> RequestPattern {
        return RequestPattern(method: "PATCH", url: url, headerFields: headerFields)
    }

    /// A new pattern for `DELETE` request.
    public static func delete(_ url: PatternRepresentable, headerFields: [String: PatternRepresentable] = [:]) -> RequestPattern {
        return RequestPattern(method: "DELETE", url: url, headerFields: headerFields)
    }

}
