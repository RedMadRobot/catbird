@testable import CatbirdApp
import CatbirdAPI
import XCTest

final class MatchPatternTests: XCTestCase {

    func testMatchEqual() {
        let pattern1 = Pattern.equal("some string")
        XCTAssertTrue(pattern1.match("some string"))

        let pattern2 = Pattern.equal("some*string")
        XCTAssertTrue(pattern2.match("some*string"))

        let pattern3 = Pattern.equal("^some.string$")
        XCTAssertTrue(pattern3.match("^some.string$"))
    }

    func testMatchWildcard() {
        let pattern1 = Pattern.wildcard("some?string")
        XCTAssertTrue(pattern1.match("some string"))
        XCTAssertTrue(pattern1.match("some_string"))
        XCTAssertTrue(pattern1.match("some-string"))
        XCTAssertFalse(pattern1.match("somestring"))
        XCTAssertFalse(pattern1.match("something"))

        let pattern2 = Pattern.wildcard("foo{bar,baz}")
        XCTAssertTrue(pattern2.match("foobar"))
        XCTAssertTrue(pattern2.match("foobaz"))
        XCTAssertFalse(pattern2.match("foobuz"))
    }

    func testMatchRegexp() {
        let pattern1 = Pattern.regexp(#"^some[\w\d-_]{1}string"#)
        XCTAssertTrue(pattern1.match("some-string"))
        XCTAssertTrue(pattern1.match("some_string"))
        XCTAssertTrue(pattern1.match("some1string"))
        XCTAssertFalse(pattern1.match("some string"))
        XCTAssertFalse(pattern1.match("some--string"))
        XCTAssertFalse(pattern1.match("somestring"))
    }

}
