import Foundation

/// Catbird API action.
public enum CatbirdAction: Equatable {
    /// Add, update or remove `ResponseMock` for `RequestPattern`.
    case update(RequestPattern, ResponseMock?)

    /// Remove all mocks.
    case removeAll
}

// MARK: - CatbirdMockConvertible

public protocol CatbirdMockConvertible {
    /// HTTP request pattern.
    var pattern: RequestPattern { get }

    /// HTTP response mock.
    var response: ResponseMock { get }
}

// MARK: - CatbirdAction + CatbirdMockConvertible

extension CatbirdAction {
    /// Add or update `ResponseMock` for `RequestPattern`.
    ///
    /// - Parameter mock: Mock representation.
    /// - Returns: A new `CatbirdAction`.
    public static func add(_ mock: CatbirdMockConvertible) -> CatbirdAction {
        CatbirdAction.update(mock.pattern, mock.response)
    }

    /// Remove `ResponseMock` for `RequestPattern`.
    ///
    /// - Parameter mock: Mock representation.
    /// - Returns: A new `CatbirdAction`.
    public static func remove(_ mock: CatbirdMockConvertible) -> CatbirdAction {
        CatbirdAction.update(mock.pattern, nil)
    }
}

// MARK: - CatbirdAction + URLRequest

extension CatbirdAction {
    private static let encoder = JSONEncoder()

    /// Create a new `URLRequest`.
    ///
    /// - Parameter url: Catbird server base url.
    /// - Returns: Request to mock server.
    func makeRequest(to url: URL) throws -> URLRequest {
        var request = URLRequest(url: url.appendingPathComponent("catbird/api/mocks"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try CatbirdAction.encoder.encode(self)
        return request
    }

}

// MARK: - Codable

extension CatbirdAction: Codable {
    enum CondingKeys: String, CodingKey {
        case pattern
        case response
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CondingKeys.self)
        let pattern = try container.decodeIfPresent(RequestPattern.self, forKey: .pattern)
        let response = try container.decodeIfPresent(ResponseMock.self, forKey: .response)

        switch (pattern, response) {
        case (let pattern?, let response):
            self = .update(pattern, response)
        case (.none, .none):
            self = .removeAll
        case (.none, .some):
            let context = DecodingError.Context(
                codingPath: [CondingKeys.pattern],
                debugDescription: "Not found `RequestPattern` for `ResponseMock`")
            throw DecodingError.valueNotFound(RequestPattern.self, context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CondingKeys.self)
        switch self {
        case .update(let pattern, let response):
            try container.encode(pattern, forKey: .pattern)
            try container.encodeIfPresent(response, forKey: .response)
        case .removeAll:
            break
        }
    }
}
