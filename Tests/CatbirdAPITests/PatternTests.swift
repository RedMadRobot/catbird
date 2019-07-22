import CatbirdAPI
import XCTest

final class PatternTests: XCTestCase {
    
    enum Samples: String {
        case equalJson = #"{"kind":"equal","value":"some"}"#
        case globJson = #"{"kind":"glob","value":"some*"}"#
        case regexpJson = #"{"kind":"regexp","value":"^some$"}"#
    }
    
    func testEncodingEqual() {
        let pattern = Pattern.equal("some")
        let data = try! JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), Samples.equalJson.rawValue)
    }
    
    func testEncodingGlob() {
        let pattern = Pattern.glob("some*")
        let data = try! JSONEncoder().encode(pattern)
        XCTAssertEqual(String(data: data, encoding: .utf8), Samples.globJson.rawValue)
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
    
    func testDecodingGlob() {
        let data = Samples.globJson.rawValue.data(using: .utf8)!
        let pattern = try! JSONDecoder().decode(Pattern.self, from: data)
        let reference = Pattern.glob("some*")
        XCTAssertEqual(pattern, reference)
    }
    
    func testDecodingRegexp() {
        let data = Samples.regexpJson.rawValue.data(using: .utf8)!
        let pattern = try! JSONDecoder().decode(Pattern.self, from: data)
        let reference = Pattern.regexp("^some$")
        XCTAssertEqual(pattern, reference)
    }
}
