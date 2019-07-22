@testable import CatbirdApp
import CatbirdAPI
import XCTest

final class GlobTests: XCTestCase {

    func match(_ globPattern: String, _ testString: String, globstar: Bool = false) -> Bool {
        return Glob(globPattern: globPattern, globstar: globstar).check(testString)
    }
    
    // MARK: - Tests
    
    func testMatch() {
        // Match everything
        XCTAssertTrue(match("*", "foo"))
        
        // Match the end
        XCTAssertTrue(match("f*", "foo"))
        
        // Match the start
        XCTAssertTrue(match("*o", "foo"))
        
        // Match the middle
        XCTAssertTrue(match("f*uck", "firetruck"))
        
        // Don't match
        XCTAssertFalse(match("uc", "firetruck"))
        
        // Match zero characters
        XCTAssertTrue(match("f*uck", "fuck"))
        
        // ?: Match one character, no more and no less
        XCTAssertTrue(match("f?o", "foo"))
        XCTAssertFalse(match("f?o", "fooo"))
        XCTAssertFalse(match("f?oo", "foo"))
        
        // []: Match a character range
        XCTAssertTrue(match("fo[oz]", "foo"))
        XCTAssertTrue(match("fo[oz]", "foz"))
        XCTAssertFalse(match("fo[oz]", "fog"))
        
        // {}: Match a choice of different substrings
        XCTAssertTrue(match("foo{bar,baaz}", "foobaaz"))
        XCTAssertTrue(match("foo{bar,baaz}", "foobar"))
        XCTAssertFalse(match("foo{bar,baaz}", "foobuzz"))
        XCTAssertTrue(match("foo{bar,b*z}", "foobuzz"))
        
        // More complex matches
        XCTAssertTrue(match("*.min.js", "http://example.com/jquery.min.js"))
        XCTAssertTrue(match("*.min.*", "http://example.com/jquery.min.js"))
        XCTAssertTrue(match("*/js/*.js", "http://example.com/js/jquery.min.js"))
        XCTAssertTrue(match("http://?o[oz].b*z.com/{*.js,*.html}",
                            "http://foo.baaz.com/jquery.min.js"))
        XCTAssertTrue(match("http://?o[oz].b*z.com/{*.js,*.html}",
                            "http://moz.buzz.com/index.html"))
        XCTAssertFalse(match("http://?o[oz].b*z.com/{*.js,*.html}",
                             "http://moz.buzz.com/index.htm"))
        XCTAssertFalse(match("http://?o[oz].b*z.com/{*.js,*.html}",
                             "http://moz.bar.com/index.html"))
        XCTAssertFalse(match("http://?o[oz].b*z.com/{*.js,*.html}",
                             "http://flozz.buzz.com/index.html"))
    }
    
    func testSpecialChars() {
        // Test string  "\\/$^+.()=!|,.*"  represents  <glob>\\/$^+.()=!|,.*</glob>
        // The equivalent regex is:  /^\\\/\$\^\+\.\(\)\=\!\|\,\..*$/
        // Both glob and regex match:  \/$^+.()=!|,.*
        let testStr = #"\\/$^+.()=!|,.*"#
        let targetStr = #"\/$^+.()=!|,.*"#
        XCTAssertTrue(match(testStr, targetStr))
    }
    
    func testGlobstarFalse() {
        XCTAssertTrue(match("http://foo.com/**/{*.js,*.html}",
                            "http://foo.com/bar/jquery.min.js"))
        XCTAssertTrue(match("http://foo.com/**/{*.js,*.html}",
                            "http://foo.com/bar/baz/jquery.min.js"))
        XCTAssertTrue(match("http://foo.com/**",
                            "http://foo.com/bar/baz/jquery.min.js"))
    }

    func testGlobstarTrue() {
        XCTAssertTrue(match("http://foo.com/**/{*.js,*.html}",
                            "http://foo.com/bar/jquery.min.js",
                            globstar: true))
        XCTAssertTrue(match("http://foo.com/**/{*.js,*.html}",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: true))
        XCTAssertTrue(match("http://foo.com/**",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: true))
        
        XCTAssertTrue(match("/foo/*", "/foo/bar.txt", globstar: true))
        XCTAssertTrue(match("/foo/**", "/foo/baz.txt", globstar: true))
        XCTAssertTrue(match("/foo/**", "/foo/bar/baz.txt", globstar: true))
        XCTAssertTrue(match("/foo/*/*.txt", "/foo/bar/baz.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/*.txt", "/foo/bar/baz.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/*.txt", "/foo/bar/baz/qux.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/bar.txt", "/foo/bar.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/**/bar.txt", "/foo/bar.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/*/baz.txt", "/foo/bar/baz.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/*.txt", "/foo/bar.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/**/*.txt", "/foo/bar.txt", globstar: true))
        XCTAssertTrue(match("/foo/**/*/*.txt", "/foo/bar/baz.txt", globstar: true))
        XCTAssertTrue(match("**/*.txt", "/foo/bar/baz/qux.txt", globstar: true))
        XCTAssertTrue(match("**/foo.txt", "foo.txt", globstar: true))
        XCTAssertTrue(match("**/*.txt", "foo.txt", globstar: true))
        
        XCTAssertFalse(match("/foo/*", "/foo/bar/baz.txt", globstar: true))
        XCTAssertFalse(match("/foo/*.txt", "/foo/bar/baz.txt", globstar: true))
        XCTAssertFalse(match("/foo/*/*.txt", "/foo/bar/baz/qux.txt", globstar: true))
        XCTAssertFalse(match("/foo/*/bar.txt", "/foo/bar.txt", globstar: true))
        XCTAssertFalse(match("/foo/*/*/baz.txt", "/foo/bar/baz.txt", globstar: true))
        XCTAssertFalse(match("/foo/**.txt", "/foo/bar/baz/qux.txt", globstar: true))
        XCTAssertFalse(match("/foo/bar**/*.txt", "/foo/bar/baz/qux.txt", globstar: true))
        XCTAssertFalse(match("/foo/bar**", "/foo/bar/baz.txt", globstar: true))
        XCTAssertFalse(match("**/.txt", "/foo/bar/baz/qux.txt", globstar: true))
        XCTAssertFalse(match("*/*.txt", "/foo/bar/baz/qux.txt", globstar: true))
        XCTAssertFalse(match("*/*.txt", "foo.txt", globstar: true))
    }
    
    func testGlobstarExt() {
        XCTAssertFalse(match("http://foo.com/*",
                             "http://foo.com/bar/baz/jquery.min.js",
                            globstar: true))
        XCTAssertTrue(match("http://foo.com/*",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: false))
        XCTAssertTrue(match("http://foo.com/**",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: true))
        XCTAssertTrue(match("http://foo.com/*/*/jquery.min.js",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: true))
        XCTAssertTrue(match("http://foo.com/**/jquery.min.js",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: true))
        XCTAssertTrue(match("http://foo.com/*/*/jquery.min.js",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: false))
        XCTAssertTrue(match("http://foo.com/*/jquery.min.js",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: false))
        XCTAssertFalse(match("http://foo.com/*/jquery.min.js",
                            "http://foo.com/bar/baz/jquery.min.js",
                            globstar: true))
    }
} 
