import Foundation

/// Catbird api command.
///
/// - add: match.
/// - remove: remove match at pattern&
/// - clear: Remove all matches.
public enum Command {
    case add(pattern: RequestPattern, data: ResponseData)
    case remove(pattern: RequestPattern)
    case clear
}

// MARK: - Command + RequestBagConvertible

extension Command {

    public static func add(_ bag: RequestBagConvertible) -> Command {
        return Command.add(pattern: bag.pattern, data: bag.responseData)
    }

    public static func remove(_ bag: RequestBagConvertible) -> Command {
        return Command.remove(pattern: bag.pattern)
    }
}

// MARK: - Command + URLRequest

extension Command {

    private static let encoder = JSONEncoder()
    private var encoder: JSONEncoder { return Command.encoder }

    /// Create a new `URLRequest`.
    ///
    /// - Parameter url: Catbird server base url.
    /// - Returns: Request to mock server.
    internal func makeRequest(to url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url.appendingPathComponent("catbird/api"))

        switch self {
        case .add(let pattern, let data):
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let bag = RequestBag(pattern: pattern, data: data)
            urlRequest.httpBody = try encoder.encode(bag)
        case .remove(let pattern):
            urlRequest.httpMethod = "DELETE"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try encoder.encode(pattern)
        case .clear:
            urlRequest.httpMethod = "DELETE"
            urlRequest.url!.appendPathComponent("clear")
        }
        return urlRequest
    }
}
