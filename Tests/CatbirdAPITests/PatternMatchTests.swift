import struct CatbirdAPI.PatternMatch
import XCTest

final class PatternMatchTests: XCTestCase {
    
    private enum JSONs: String {
        case equal = #"{"kind":"equal","value":"some"}"#
        case wildcard = #"{"kind":"wildcard","value":"some*"}"#
        case regexp = #"{"kind":"regexp","value":"^some$"}"#

        var data: Data { Data(rawValue.utf8) }
    }
    
    func testEncodingEqual() throws {
        let pattern = PatternMatch.equal("some")
        let data = try JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), JSONs.equal.rawValue)
    }
    
    func testEncodingWildcard() throws {
        let pattern = PatternMatch.wildcard("some*")
        let data = try JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), JSONs.wildcard.rawValue)
    }
    
    func testEncodingRegexp() throws {
        let pattern = PatternMatch.regexp("^some$")
        let data = try JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), JSONs.regexp.rawValue)
    }
    
    func testDecodingEqual() throws {
        let data = JSONs.equal.data
        let pattern = try JSONDecoder().decode(PatternMatch.self, from: data)
        let reference = PatternMatch.equal("some")
        XCTAssertEqual(pattern, reference)
    }
    
    func testDecodingWildcard() throws {
        let data = JSONs.wildcard.data
        let pattern = try JSONDecoder().decode(PatternMatch.self, from: data)
        let reference = PatternMatch.wildcard("some*")
        XCTAssertEqual(pattern, reference)
    }
    
    func testDecodingRegexp() throws {
        let data = JSONs.regexp.data
        let pattern = try JSONDecoder().decode(PatternMatch.self, from: data)
        let reference = PatternMatch.regexp("^some$")
        XCTAssertEqual(pattern, reference)
    }
}
