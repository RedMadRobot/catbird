@testable import CatbirdApp
import CatbirdAPI
import XCTest

final class WildcardTests: XCTestCase {

    func match(_ pattern: String, _ testString: String) -> Bool {
        return Wildcard(pattern: pattern).check(testString)
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
        // Test string  "\\/$^+.()=!|,.*"  represents  <wildcard>\\/$^+.()=!|,.*</wildcard>
        // The equivalent regex is:  /^\\\/\$\^\+\.\(\)\=\!\|\,\..*$/
        // Both wildcard and regex match:  \/$^+.()=!|,.*
        let testStr = #"\\/$^+.()=!|,.*"#
        let targetStr = #"\/$^+.()=!|,.*"#
        XCTAssertTrue(match(testStr, targetStr))
    }

    func testStars() {
        XCTAssertTrue(match("http://foo.com/**/{*.js,*.html}",
                            "http://foo.com/bar/jquery.min.js"))
        XCTAssertTrue(match("http://foo.com/**/{*.js,*.html}",
                            "http://foo.com/bar/baz/jquery.min.js"))
        XCTAssertTrue(match("http://foo.com/**",
                            "http://foo.com/bar/baz/jquery.min.js"))
    }

    func testEscaping() {
        XCTAssertTrue(match("\\*o", "*o"))
        XCTAssertFalse(match("\\*o", "foo"))

        XCTAssertTrue(match("\\?o", "?o"))
        XCTAssertFalse(match("\\?o", "fo"))

        XCTAssertTrue(match("\\", "\\"))
    }
}
