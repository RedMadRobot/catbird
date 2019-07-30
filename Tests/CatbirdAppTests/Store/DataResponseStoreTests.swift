import CatbirdAPI
@testable import CatbirdApp
import Vapor
import XCTest

final class DataResponseStoreTests: RequestTestCase {
    
    func testSetResponse() {
        let store = DataResponseStore()
        XCTAssertEqual(store.bags.count, 0)
        
        let data = ResponseData(statusCode: 200, headerFields: [:], body: nil)
        let pattern = RequestPattern.get("/login", headerFields: [:])
        try! store.setResponse(data: data, for: pattern)
        XCTAssertEqual(store.bags.count, 1)
        
        try! store.setResponse(data: data, for: pattern)
        XCTAssertEqual(store.bags.count, 1)
        
        // Remove by setting nil
        try! store.setResponse(data: nil, for: pattern)
        XCTAssertEqual(store.bags.count, 0)
    }
    
    func testSetResponse_replace() {
        let store = DataResponseStore()
        let data1 = ResponseData(statusCode: 200, headerFields: [:], body: nil)
        let data2 = ResponseData(statusCode: 400, headerFields: [:], body: nil)
        XCTAssertNotEqual(data1, data2)
        let pattern = RequestPattern.get("/login", headerFields: [:])
        
        try! store.setResponse(data: data1, for: pattern)
        XCTAssertEqual(store.bags.count, 1)
        XCTAssertEqual(store.bags.first!.data, data1)
        
        // Check data override
        try! store.setResponse(data: data2, for: pattern)
        XCTAssertEqual(store.bags.count, 1)
        XCTAssertEqual(store.bags.first!.data, data2)
    }
    
    func testSetResponseForDifferentUrlPattern() {
        let store = DataResponseStore()
        
        let data = ResponseData(statusCode: 200, headerFields: [:], body: nil)
        let pattern1 = RequestPattern.get(Pattern.equal("/login"), headerFields: [:])
        try! store.setResponse(data: data, for: pattern1)
        
        let pattern2 = RequestPattern.get(Pattern.wildcard("/login"), headerFields: [:])
        try! store.setResponse(data: data, for: pattern2)
        
        let pattern3 = RequestPattern.get(Pattern.regexp("/login"), headerFields: [:])
        try! store.setResponse(data: data, for: pattern3)
        
        XCTAssertEqual(store.bags.count, 3)
    }
    
    func testRemoveAllResponses() {
        let store = DataResponseStore()
        let data = ResponseData(statusCode: 200, headerFields: [:], body: nil)
        let pattern = RequestPattern.get("/login", headerFields: [:])
        try! store.setResponse(data: data, for: pattern)
        XCTAssertEqual(store.bags.count, 1)
        
        try! store.removeAllResponses()
        XCTAssertEqual(store.bags.count, 0)
    }
    
    func testResponseForRequest_match() {
        let store = DataResponseStore()
        let data = ResponseData(statusCode: 200, headerFields: [:], body: Data())
        let pattern = RequestPattern.get("/login", headerFields: ["Access-Token":"xyz"])
        try! store.setResponse(data: data, for: pattern)
        
        let request = makeRequest(
            http: HTTPRequest(
                method: HTTPMethod.GET,
                url: "/login",
                headers: HTTPHeaders([("Access-Token", "xyz")])
            )
        )
        
        XCTAssertNoThrow(try {
            let result = try store.response(for: request)
            XCTAssertEqual(result.http.status.code, 200)
            XCTAssertEqual(result.http.body.data, Data())
        }())
    }
    
    func testResponseForRequest_notMatch() {
        let store = DataResponseStore()
        let data = ResponseData(statusCode: 200, headerFields: [:], body: Data())
        let pattern = RequestPattern.get("/login", headerFields: [:])
        try! store.setResponse(data: data, for: pattern)
        
        let request = makeRequest(
            http: HTTPRequest(
                method: HTTPMethod.GET,
                url: "/user"
            )
        )
        
        XCTAssertThrowsError(try store.response(for: request)) { (error: Error) in
            XCTAssertTrue(error is AbortError)
        }
    }
}
