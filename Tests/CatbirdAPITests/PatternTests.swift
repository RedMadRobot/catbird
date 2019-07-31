import struct CatbirdAPI.Pattern
import XCTest

final class PatternTests: XCTestCase {
    
    enum Samples: String {
        case equalJson = #"{"kind":"equal","value":"some"}"#
        case wildcardJson = #"{"kind":"wildcard","value":"some*"}"#
        case regexpJson = #"{"kind":"regexp","value":"^some$"}"#
    }
    
    func testEncodingEqual() {
        let pattern = Pattern.equal("some")
        let data = try! JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), Samples.equalJson.rawValue)
    }
    
    func testEncodingWildcard() {
        let pattern = Pattern.wildcard("some*")
        let data = try! JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), Samples.wildcardJson.rawValue)
    }
    
    func testEncodingRegexp() {
        let pattern = Pattern.regexp("^some$")
        let data = try! JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), Samples.regexpJson.rawValue)
    }
    
    func testDecodingEqual() {
        let data = Samples.equalJson.rawValue.data(using: .utf8)!
        let pattern = try! JSONDecoder().decode(Pattern.self, from: data)
        let reference = Pattern.equal("some")
        XCTAssertEqual(pattern, reference)
    }
    
    func testDecodingWildcard() {
        let data = Samples.wildcardJson.rawValue.data(using: .utf8)!
        let pattern = try! JSONDecoder().decode(Pattern.self, from: data)
        let reference = Pattern.wildcard("some*")
        XCTAssertEqual(pattern, reference)
    }
    
    func testDecodingRegexp() {
        let data = Samples.regexpJson.rawValue.data(using: .utf8)!
        let pattern = try! JSONDecoder().decode(Pattern.self, from: data)
        let reference = Pattern.regexp("^some$")
        XCTAssertEqual(pattern, reference)
    }
}
