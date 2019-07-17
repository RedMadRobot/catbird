import CatbirdAPI
import XCTest

final class CatbirdTests: XCTestCase {

    private var catbird: Catbird!
    private var session: URLSession!
    private let decoder = JSONDecoder()
    private let baseURL = URL(string: "https://example.com")!
    private var urlProtocols: [URLProtocol] { return MockURLProtocol.protocols }

    override func setUp() {
        super.setUp()
        let configuration = Catbird.session.configuration
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        catbird = Catbird(url: baseURL, session: session)
    }

    override func tearDown() {
        super.tearDown()
        session.invalidateAndCancel()
        MockURLProtocol.clear()
    }

    func testSendCommandAdd() {
        // Given
        let pattern = RequestPattern.put(URL(string: "/profile")!)
        let data = ResponseData(statusCode: 400)
        let bag = RequestBag(pattern: pattern, data: data)
        MockURLProtocol.result = .success(makeResponse(status: 200))

        // When
        XCTAssertNoThrow(try catbird.send(.add(pattern: pattern, data: data)))

        // Then
        XCTAssertEqual(urlProtocols.count, 1)
        guard let request = urlProtocols.first?.request else { return }
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, URL(string: "https://example.com/catbird/api")!)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(try decode(RequestBag.self, from: request), bag)
    }

    func testSendCommandRemove() {
        // Given
        let pattern = RequestPattern.get(URL(string: "/about")!)
        MockURLProtocol.result = .success(makeResponse(status: 200))

        // When
        XCTAssertNoThrow(try catbird.send(.remove(pattern: pattern)))

        // Then
        XCTAssertEqual(urlProtocols.count, 1)
        guard let request = urlProtocols.first?.request else { return }
        XCTAssertEqual(request.httpMethod, "DELETE")
        XCTAssertEqual(request.url, URL(string: "https://example.com/catbird/api")!)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(try decode(RequestPattern.self, from: request), pattern)
    }

    func testSendCommandClear() {
        // Given
        MockURLProtocol.result = .success(makeResponse(status: 200))

        // When
        XCTAssertNoThrow(try catbird.send(.clear))

        // Then
        XCTAssertEqual(urlProtocols.count, 1)
        guard let request = urlProtocols.first?.request else { return }
        XCTAssertEqual(request.httpMethod, "DELETE")
        XCTAssertEqual(request.url, URL(string: "https://example.com/catbird/api/clear")!)
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertNil(request.httpBody)
    }

    @available(iOS 7, macOS 10.13, *)
    func testURLError() {
        // Given
        let connectionError = URLError(.networkConnectionLost)
        MockURLProtocol.result = .failure(connectionError)

        // When
        XCTAssertThrowsError(try catbird.send(.clear)) { (error: Error) in
            // Then
            XCTAssertEqual(error as NSError, connectionError as NSError)
        }
    }

    // MARK: - Private

    private func decode<T>(_ type: T.Type, from urlRequest: URLRequest) throws -> T? where T : Decodable {
        return try urlRequest.httpBody.map { try decoder.decode(type, from: $0) }
    }

    private func makeResponse(status: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: baseURL, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
