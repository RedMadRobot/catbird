@testable import CatbirdAPI
import XCTVapor

extension Application {

    func perform(_ action: CatbirdAction, parallelId: String? = nil, file: StaticString = #file, line: UInt = #line) throws {
        let request = try action.makeHTTPRequest(to: URL(string: "/")!, parallelId: parallelId)
        let method = HTTPMethod(rawValue: request.httpMethod)
        let path = request.url.path
        var headers = HTTPHeaders()
        request.headers.forEach { key, value in
            headers.add(name: key, value: value)
        }
        let body = request.httpBody.map { (data: Data) -> ByteBuffer in
            var buffer = allocator.buffer(capacity: data.count)
            buffer.writeBytes(data)
            return buffer
        }
        try test(method, path, headers: headers, body: body, file: file, line: line) { response in
            XCTAssertEqual(response.status, action.expectedStatus, "Response status", file: file, line: line)
            XCTAssertEqual(response.body.string, "", "Response body", file: file, line: line)
        }
    }
}

extension CatbirdAction {
    var expectedStatus: HTTPResponseStatus {
        switch self {
        case .update:
            return .created
        case .remove, .removeAll:
            return .noContent
        }
    }
}
