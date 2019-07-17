import Foundation

/// The matching pattern of the request to the server.
///
/// The intercepted request must return `ResponseData`.
public struct RequestPattern: Codable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
        hasher.combine(method)
    }
    
    /// HTTP method.
    public let method: String

    /// Request URL.
    public let url: URL

    /// Request required headers. Default empty.
    public let headerFields: [String: String]

    /// A new request pattern.
    ///
    /// - Parameters:
    ///   - method: HTTP method.
    ///   - url: Request URL.
    ///   - headerFields: Request required headers. Default empty.
    public init(method: String, url: URL, headerFields: [String: String] = [:]) {
        self.method = method
        self.url = url
        self.headerFields = headerFields
    }

    /// A new pattern for `GET` request.
    public static func get(_ url: URL, headerFields: [String: String] = [:]) -> RequestPattern {
        return RequestPattern(method: "GET", url: url, headerFields: headerFields)
    }

    /// A new pattern for `POST` request.
    public static func post(_ url: URL, headerFields: [String: String] = [:]) -> RequestPattern {
        return RequestPattern(method: "POST", url: url, headerFields: headerFields)
    }

    /// A new pattern for `PUT` request.
    public static func put(_ url: URL, headerFields: [String: String] = [:]) -> RequestPattern {
        return RequestPattern(method: "PUT", url: url, headerFields: headerFields)
    }

    /// A new pattern for `PATCH` request.
    public static func patch(_ url: URL, headerFields: [String: String] = [:]) -> RequestPattern {
        return RequestPattern(method: "PATCH", url: url, headerFields: headerFields)
    }

    /// A new pattern for `DELETE` request.
    public static func delete(_ url: URL, headerFields: [String: String] = [:]) -> RequestPattern {
        return RequestPattern(method: "DELETE", url: url, headerFields: headerFields)
    }

}
