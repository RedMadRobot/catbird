import Foundation

/// The kind of pattern for matching request fields such as url and headers
public struct Pattern: Codable, Hashable {
    
    // MARK: - Public types
    
    /// - equal: The request value must be equal pattern value
    /// - glob: The request value match with glob pattern
    /// - regexp: The request value match with regular expression pattern
    public enum Kind: String, Codable {
        case equal, glob, regexp
    }
    
    
    // MARK: - Public properties
    
    public let kind: Kind
    public let value: String
    
    
    // MARK: - Init
    
    public init(kind: Kind, value: String) {
        self.kind = kind
        self.value = value
    }
    
    public static func equal(_ value: String) -> Pattern {
        return Pattern(kind: .equal, value: value)
    }
    
    public static func glob(_ value: String) -> Pattern {
        return Pattern(kind: .glob, value: value)
    }
    
    public static func regexp(_ value: String) -> Pattern {
        return Pattern(kind: .regexp, value: value)
    }
}


/// Protocol for converting common types to Pattern
public protocol PatternRepresentable {
    var pattern: Pattern { get }
}

extension Pattern: PatternRepresentable {
    public var pattern: Pattern {
        return self
    }
}

extension String: PatternRepresentable {
    public var pattern: Pattern {
        return .equal(self)
    }
}

extension URL: PatternRepresentable {
    public var pattern: Pattern {
        return .equal(self.absoluteString)
    }
}
