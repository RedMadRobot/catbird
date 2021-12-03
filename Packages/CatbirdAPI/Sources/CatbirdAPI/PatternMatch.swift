import Foundation

/// The kind of pattern for matching request fields such as url and headers
public struct PatternMatch: Codable, Hashable {
    
    // MARK: - Public types
    
    /// - equal: The request value must be equal to the pattern value
    /// - wildcard: The request value match with the wildcard pattern
    /// - regexp: The request value match with the regular expression pattern
    public enum Kind: String, Codable {
        case equal, wildcard, regexp
    }
    
    
    // MARK: - Public properties
    
    public let kind: Kind
    public let value: String
    
    
    // MARK: - Init
    
    public init(kind: Kind, value: String) {
        self.kind = kind
        self.value = value
    }
    
    public static func equal(_ value: String) -> PatternMatch {
        return PatternMatch(kind: .equal, value: value)
    }
    
    public static func wildcard(_ value: String) -> PatternMatch {
        return PatternMatch(kind: .wildcard, value: value)
    }
    
    public static func regexp(_ value: String) -> PatternMatch {
        return PatternMatch(kind: .regexp, value: value)
    }
}


/// Protocol for converting common types to Pattern
public protocol PatternRepresentable {
    var pattern: PatternMatch { get }
}

extension PatternMatch: PatternRepresentable {
    public var pattern: PatternMatch {
        return self
    }
}

extension String: PatternRepresentable {
    public var pattern: PatternMatch {
        return .equal(self)
    }
}

extension URL: PatternRepresentable {
    public var pattern: PatternMatch {
        return .equal(self.absoluteString)
    }
}
