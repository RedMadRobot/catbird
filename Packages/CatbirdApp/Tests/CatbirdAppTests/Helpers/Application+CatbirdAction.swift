@testable import CatbirdAPI
import XCTVapor

extension Application {

    func perform(_ action: CatbirdAction, file: StaticString = #file, line: UInt = #line) throws {
        let request = try action.makeRequest(to: URL(string: "/")!)
        let method = try XCTUnwrap(request.httpMethod.map { HTTPMethod(rawValue: $0) }, file: file, line: line)
        let path = try XCTUnwrap(request.url?.path, file: file, line: line)
        var headers = HTTPHeaders()
        request.allHTTPHeaderFields?.forEach { key, value in
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
