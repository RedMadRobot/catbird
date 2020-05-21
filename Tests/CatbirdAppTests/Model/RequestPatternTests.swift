@testable import CatbirdApp
import CatbirdAPI
import Vapor
import XCTest

//final class RequestPatternTests: RequestTestCase {
//    
//    func testMakeGet() {
//        let pattern = RequestPattern.get("/", headerFields: ["Key": "Value"])
//        XCTAssertEqual(pattern.method, "GET")
//        XCTAssertEqual(pattern.url, Pattern.equal("/"))
//        XCTAssertEqual(pattern.headerFields, ["Key": Pattern.equal("Value")])
//    }
//    
//    func testMakePost() {
//        let pattern = RequestPattern.post("/", headerFields: ["Key": "Value"])
//        XCTAssertEqual(pattern.method, "POST")
//        XCTAssertEqual(pattern.url, Pattern.equal("/"))
//        XCTAssertEqual(pattern.headerFields, ["Key": Pattern.equal("Value")])
//    }
//    
//    func testMakePut() {
//        let pattern = RequestPattern.put("/", headerFields: ["Key": "Value"])
//        XCTAssertEqual(pattern.method, "PUT")
//        XCTAssertEqual(pattern.url, Pattern.equal("/"))
//        XCTAssertEqual(pattern.headerFields, ["Key": Pattern.equal("Value")])
//    }
//    
//    func testMakeDelete() {
//        let pattern = RequestPattern.delete("/", headerFields: ["Key": "Value"])
//        XCTAssertEqual(pattern.method, "DELETE")
//        XCTAssertEqual(pattern.url, Pattern.equal("/"))
//        XCTAssertEqual(pattern.headerFields, ["Key": Pattern.equal("Value")])
//    }
//    
//    func testMakePatch() {
//        let pattern = RequestPattern.patch("/", headerFields: ["Key": "Value"])
//        XCTAssertEqual(pattern.method, "PATCH")
//        XCTAssertEqual(pattern.url, Pattern.equal("/"))
//        XCTAssertEqual(pattern.headerFields, ["Key": Pattern.equal("Value")])
//    }
//    
//    func testInitWithHTTPRequest() {
//        let httpRequest = HTTPRequest(method: HTTPMethod.GET, url: "/login", headers: HTTPHeaders([("Key", "Value")]))
//        let pattern = RequestPattern(httpRequest: httpRequest)
//        XCTAssertEqual(pattern.method, "GET")
//        XCTAssertEqual(pattern.url, Pattern.equal("/login"))
//        XCTAssertEqual(pattern.headerFields, ["content-length": Pattern.equal("0"), "Key": Pattern.equal("Value")])
//    }
//    
//    func testMatchByUrl() {
//        let pattern = RequestPattern.get("/login")
//        let httpRequest1 = HTTPRequest(method: HTTPMethod.GET, url: "/login" )
//        XCTAssertTrue(pattern.match(httpRequest1))
//        
//        let httpRequest2 = HTTPRequest(method: HTTPMethod.GET, url: "/login/" )
//        XCTAssertFalse(pattern.match(httpRequest2))
//    }
//    
//    func testMatchByUrlWithWildcard() {
//        let pattern = RequestPattern.get(Pattern.wildcard("http://foo.com/*.txt"))
//        let httpRequest1 = HTTPRequest(method: HTTPMethod.GET, url: "http://foo.com/readme.txt")
//        XCTAssertTrue(pattern.match(httpRequest1))
//        
//        let httpRequest2 = HTTPRequest(method: HTTPMethod.GET, url: "http://foo.com/txt")
//        XCTAssertFalse(pattern.match(httpRequest2))
//    }
//    
//    func testMatchByUrlWithRegexp() {
//        let pattern = RequestPattern.get(Pattern.regexp(#"http://foo.com/.+\.txt"#))
//        let httpRequest1 = HTTPRequest(method: HTTPMethod.GET, url: "http://foo.com/readme.txt")
//        XCTAssertTrue(pattern.match(httpRequest1))
//        
//        let httpRequest2 = HTTPRequest(method: HTTPMethod.GET, url: "http://foo.com/txt")
//        XCTAssertFalse(pattern.match(httpRequest2))
//    }
//    
//    func testMatchByHeaders() {
//        let pattern = RequestPattern.get("/", headerFields: ["Key": "Value"])
//        let httpRequest = HTTPRequest(
//            method: .GET,
//            url: "/",
//            headers: HTTPHeaders([("Key", "Value"), ("Key1", "Value1"), ("Key2", "Value2")]))
//        XCTAssertTrue(pattern.match(httpRequest))
//    }
//    
//    func testNotMatchByHeaders() {
//        let pattern = RequestPattern.get("/", headerFields: ["Key": "Value"])
//        let httpRequest = HTTPRequest(
//            method: .GET,
//            url: "/",
//            headers: HTTPHeaders([("Key1", "Value1"), ("Key2", "Value2")]))
//        XCTAssertFalse(pattern.match(httpRequest))
//    }
//}
