import Foundation

/// Convert wildcard pattern to regular expression and check string match.
public struct Wildcard {
    
    let pattern: String

    public init(pattern: String) {
        self.pattern = pattern
    }
    
    /// Translate wildcard pattern to regular expression pattern
    ///
    /// - Returns: Regular expression pattern string
    public func regexPattern() -> String {
        let patternChars = [Character](pattern)
        var result = ""
        var index = 0
        var inGroup = false
        
        while index < patternChars.count {
            let char = patternChars[index]
            
            switch char {
            case "/", "$", "^", "+", ".", "(", ")", "=", "!", "|":
                result.append("\\\(char)")
            case "\\":
                // Escaping next character
                if index + 1 < patternChars.count {
                    result.append("\\")
                    result.append(patternChars[index + 1])
                    index += 1
                } else {
                    result.append("\\\\")
                }
            case "?":
                result.append(".")
            case "[", "]":
                result.append(char)
            case "{":
                inGroup = true
                result.append("(")
            case "}":
                inGroup = false
                result.append(")")
            case ",":
                if inGroup {
                    result.append("|")
                } else {
                    result.append("\\\(char)")
                }
            case "*":
                // Move over all consecutive "*"'s.
                while(index + 1 < patternChars.count && patternChars[index + 1] == "*") {
                    index += 1
                }
                // Treat any number of "*" as one
                result.append(".*")
            default:
                result.append(char)
            }
            index += 1
        }
        
        return "^\(result)$"
    }
    
    /// Make regular expression object from wildcard pattern
    ///
    /// - Returns: An instance of NSRegularExpression
    public func toRegex(caseInsensitive: Bool = true) throws -> NSRegularExpression {
        var options: NSRegularExpression.Options = [.anchorsMatchLines]
        if caseInsensitive {
            options = options.union([.caseInsensitive])
        }
        return try NSRegularExpression(pattern: regexPattern(), options: options)
    }
    
    /// Checks that given string match to wildcard pattern
    public func check(_ testingString: String, caseInsensitive: Bool = true) -> Bool {
        var options: String.CompareOptions = [.regularExpression]
        if caseInsensitive {
            options = options.union([.caseInsensitive])
        }
        return testingString.range(of: regexPattern() , options: options) != nil
    }
}
