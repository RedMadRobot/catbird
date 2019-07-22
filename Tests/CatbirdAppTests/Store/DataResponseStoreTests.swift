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
    }
    
    func testSetResponseForDifferentUrlPattern() {
        let store = DataResponseStore()
        
        let data = ResponseData(statusCode: 200, headerFields: [:], body: nil)
        let pattern1 = RequestPattern.get(Pattern.equal("/login"), headerFields: [:])
        try! store.setResponse(data: data, for: pattern1)
        
        let pattern2 = RequestPattern.get(Pattern.glob("/login"), headerFields: [:])
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
        
        do {
            let result = try store.response(for: request)
            XCTAssertEqual(result.http.status.code, 200)
            XCTAssertEqual(result.http.body.data, Data())
        } catch is AbortError {
            XCTFail("Not found pattern for given request")
        } catch let error {
            XCTFail("\(error)")
        }
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
