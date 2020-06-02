@testable import CatbirdAPI
import XCTest

enum BookMock: CatbirdMockConvertible {
    case first

    var pattern: RequestPattern {
        .init(method: .PUT, url: "/books/1")
    }

    var response: ResponseMock {
        .init(status: 200, body: Data("first book".utf8))
    }
}

final class CatbirdTests: XCTestCase {

    private var catbird: Catbird!
    private var session: URLSession!
    private let url = URL(string: "https://example.com")!
    private var requests: [URLRequest] { Network.requests }

    override func setUp() {
        super.setUp()
        let configuration = Catbird.session.configuration
        configuration.protocolClasses = [Network.self]
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        catbird = Catbird(url: url, session: session)
    }

    override func tearDown() {
        super.tearDown()
        session.invalidateAndCancel()
        Network.clear()
    }

    func testSendActionAdd() throws {
        // Given
        let action = CatbirdAction.add(BookMock.first)
        Network.result = .success(response(status: 200))

        // When
        XCTAssertNoThrow(try catbird.send(action))

        // Then
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first, try action.makeRequest(to: url))
    }

    func testSendActionRemove() throws {
        // Given
        let action = CatbirdAction.remove(BookMock.first)
        Network.result = .success(response(status: 200))

        // When
        XCTAssertNoThrow(try catbird.send(action))

        // Then
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first, try action.makeRequest(to: url))
    }

    func testSendActionRemoveAll() throws {
        // Given
        let action = CatbirdAction.removeAll
        Network.result = .success(response(status: 200))

        // When
        XCTAssertNoThrow(try catbird.send(action))

        // Then
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first, try action.makeRequest(to: url))
    }

    @available(iOS 7, macOS 10.13, *)
    func testURLError() {
        // Given
        let connectionError = URLError(.networkConnectionLost)
        Network.result = .failure(connectionError)

        // When
        XCTAssertThrowsError(try catbird.send(.removeAll)) { (error: Error) in
            // Then
            XCTAssertEqual(error as NSError, connectionError as NSError)
        }
    }

    // MARK: - Private

    private func response(status: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
