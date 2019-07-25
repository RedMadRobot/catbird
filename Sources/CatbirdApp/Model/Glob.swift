import Foundation

/// Convert glob pattern to regualr expression and check string match.
/// This is Swift implementation of the JS library https://github.com/fitzgen/glob-to-regexp
public struct Glob {
    
    let pattern: String
    
    /// When globstar is _false_ (default), `'/foo/*'` is translated a regexp like
    /// `'^\/foo\/.*$'` which will match any string beginning with `'/foo/'`
    /// When globstar is _true_, `'/foo/*'` is translated to regexp like
    /// `'^\/foo\/[^/]*$'` which will match any string beginning with `'/foo/'` BUT
    /// which does not have a '/' to the right of it.
    /// E.g. with `'/foo/*'` these will match: `'/foo/bar'`, `'/foo/bar.txt'` but
    /// these will not `'/foo/bar/baz'`, `'/foo/bar/baz.txt'`
    /// Lastely, when globstar is _true_, `'/foo/**'` is equivelant to `'/foo/*'` when
    /// globstar is _false_
    let globstar: Bool
    
    
    /// - Parameters:
    ///   - globPattern: Glob pattern
    ///   - globstar: see `globstar` property
    public init(pattern: String, globstar: Bool = false) {
        self.pattern = pattern
        self.globstar = globstar
    }
    
    /// Translate glob pattern to regular expression pattern
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
                // Also store the previous and next characters
                let prevChar: Character? = index > 0 ? patternChars[index - 1] : nil
                var starCount = 1
                while(index + 1 < patternChars.count && patternChars[index + 1] == "*") {
                    starCount += 1
                    index += 1
                }
                let nextChar: Character? = index + 1 < patternChars.count ? patternChars[index + 1] : nil
                
                if !globstar {
                    // globstar is disabled, so treat any number of "*" as one
                    result.append(".*")
                } else {
                    // globstar is enabled, so determine if this is a globstar segment
                    let isGlobstar = starCount > 1               // multiple "*"'s
                        && (prevChar == "/" || prevChar == nil)  // from the start of the segment
                        && (nextChar == "/" || nextChar == nil)  // to the end of the segment
                    
                    if isGlobstar {
                        // it's a globstar, so match zero or more path segments
                        result.append("((?:[^/]*(?:/|$))*)")
                        index += 1 // move over the "/"
                    } else {
                        // it's not a globstar, so only match one path segment
                        result.append("([^/]*)")
                    }
                }
            default:
                result.append(char)
            }
            index += 1
        }
        
        return "^\(result)$"
    }
    
    /// Make regular expression object from glob pattern
    ///
    /// - Returns: An instance of NSRegularExpression
    public func toRegex(caseInsensitive: Bool = true) throws -> NSRegularExpression {
        var options: NSRegularExpression.Options = [.anchorsMatchLines]
        if caseInsensitive {
            options = options.union([.caseInsensitive])
        }
        return try NSRegularExpression(pattern: regexPattern(), options: options)
    }
    
    /// Checks that given string match to glob pattern
    public func check(_ testingString: String, caseInsensitive: Bool = true) -> Bool {
        var options: String.CompareOptions = [.regularExpression]
        if caseInsensitive {
            options = options.union([.caseInsensitive])
        }
        return testingString.range(of: regexPattern() , options: options) != nil
    }
}
