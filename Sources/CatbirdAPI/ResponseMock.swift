import Foundation

/// Response to the intercepted request.
///
/// - SeeAlso: `RequestPattern`.
public struct ResponseMock: Equatable, Codable {

    /// HTTP status code. Default 200 (Ok).
    public var status: Int

    /// Additional response headers.
    public var headers: [String: String]

    /// Response body. Default `nil`.
    public var body: Data?

    /// Maximum number of processed requests. Default `nil` (Unlimited).
    public var limit: Int?

    /// Response delay seconds. Default `nil`.
    public var delay: Int?

    /// A new response data.
    ///
    /// - Parameters:
    ///   - status: HTTP status code. Default 200 (Ok).
    ///   - headers: Additional response headers.
    ///   - body: Response body. Default `nil`.
    ///   - limit: Maximum number of processed requests. Default `nil` (Unlimited).
    ///   - delay: Response delay seconds. Default `nil`.
    public init(
        status: Int = 200,
        headers: [String: String] = [:],
        body: Data? = nil,
        limit: Int? = nil,
        delay: Int? = nil) {

        self.status = status
        self.headers = headers
        self.body = body
        self.limit = limit
        self.delay = delay
    }
}
