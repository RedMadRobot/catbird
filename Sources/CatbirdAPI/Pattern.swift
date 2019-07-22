import Foundation

/// The kind of pattern for matching request fields such as url and headers
///
/// - equal: The request value must be equal pattern value
/// - glob: The request value match with glob pattern
/// - regexp: The request value match with regular expression pattern
public enum Pattern: Codable, Equatable {
    
    /// Example: `/api/users/0`
    case equal(String)
    
    /// Example: `/api/users/*`
    case glob(String)
    
    /// Example: `^api/users/.+$`
    case regexp(String)
    
    
    // MARK: - Private types
    
    private enum Kind: String, Codable {
        case equal, glob, regexp
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind, value
    }
    
    
    // MARK: - Public properties
    
    public var value: String {
        switch self {
        case .equal(let value):
            return value
        case .glob(let value):
            return value
        case .regexp(let value):
            return value
        }
    }
    
    
    // MARK: - Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        let value = try container.decode(String.self, forKey: .value)
        switch kind {
        case .equal:
            self = .equal(value)
        case .glob :
            self = .glob(value)
        case .regexp :
            self = .glob(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .equal(let value):
            try container.encode(Kind.equal, forKey: .kind)
            try container.encode(value, forKey: .value)
        case .glob(let value):
            try container.encode(Kind.glob, forKey: .kind)
            try container.encode(value, forKey: .value)
        case .regexp(let value):
            try container.encode(Kind.regexp, forKey: .kind)
            try container.encode(value, forKey: .value)
        }
    }
}
