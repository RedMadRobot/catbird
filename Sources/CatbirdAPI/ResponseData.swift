import Foundation

/// Response to the intercepted request.
///
/// - SeeAlso: `RequestPattern`.
public struct ResponseData: Codable, Equatable {

    /// HTTP status code. Default 200 (Ok).
    public let statusCode: Int

    /// Additional response headers. Default empty.
    public let headerFields: [String: String]

    /// Response body. Default `nil`.
    public let body: Data?

    /// A new response data.
    ///
    /// - Parameters:
    ///   - statusCode: HTTP status code. Default 200 (Ok).
    ///   - headerFields: Additional response headers. Default empty.
    ///   - body: Response body. Default `nil`.
    public init(
        statusCode: Int = 200,
        headerFields: [String: String] = [:],
        body: Data? = nil) {

        self.statusCode = statusCode
        self.headerFields = headerFields
        self.body = body
    }
}
