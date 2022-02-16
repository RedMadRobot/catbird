import Foundation

/// Catbird API action.
public enum CatbirdAction: Equatable {
    /// Add, or insert `ResponseMock` for `RequestPattern`.
    case update(RequestPattern, ResponseMock)

    /// Remove `ResponseMock` for `RequestPattern`.
    case remove(RequestPattern)

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
        CatbirdAction.remove(mock.pattern)
    }
}

// MARK: - CatbirdAction + Request

extension CatbirdAction {
    /// Header name for parallel ID.
    public static let parallelIdHeaderField = "X-Catbird-Parallel-Id"

    private static let encoder = JSONEncoder()

    struct HTTPRequest {
        var httpMethod: String
        var url: URL
        var headers: [String: String]
        var httpBody: Data?

        func value(forHTTPHeaderField name: String) -> String? {
            headers[name]
        }
    }

    func makeHTTPRequest(to url: URL, parallelId: String? = nil) throws -> HTTPRequest {
        var request = HTTPRequest(
            httpMethod: "POST",
            url: url.appendingPathComponent("catbird/api/mocks"),
            headers: ["Content-Type": "application/json"],
            httpBody: try CatbirdAction.encoder.encode(self))

        if let parallelId = parallelId {
            request.headers[CatbirdAction.parallelIdHeaderField] = parallelId
        }
        return request
    }
}

// MARK: - Codable

enum CatbirdActionType: String, Codable {
    case update
    case remove
    case removeAll
}

extension CatbirdAction: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case pattern
        case response
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CatbirdActionType.self, forKey: .type)

        switch type {
        case .update:
            let pattern = try container.decode(RequestPattern.self, forKey: .pattern)
            let response = try container.decode(ResponseMock.self, forKey: .response)
            self = .update(pattern, response)
        case .remove:
            let pattern = try container.decode(RequestPattern.self, forKey: .pattern)
            self = .remove(pattern)
        case .removeAll:
            self = .removeAll
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .update(let pattern, let response):
            try container.encode(CatbirdActionType.update, forKey: .type)
            try container.encode(pattern, forKey: .pattern)
            try container.encode(response, forKey: .response)
        case .remove(let pattern):
            try container.encode(CatbirdActionType.remove, forKey: .type)
            try container.encode(pattern, forKey: .pattern)
        case .removeAll:
            try container.encode(CatbirdActionType.removeAll, forKey: .type)
        }
    }
}
