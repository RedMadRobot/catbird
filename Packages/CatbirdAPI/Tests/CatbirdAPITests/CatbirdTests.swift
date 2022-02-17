#if !os(Linux)

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

    func testParallelId() {
        // Given
        let parallelId = name
        catbird.parallelId = parallelId
        let actions: [CatbirdAction] = [
            CatbirdAction.remove(BookMock.first),
            CatbirdAction.remove(BookMock.first),
            CatbirdAction.removeAll
        ]
        Network.result = .success(response(status: 200))

        // When
        for action in actions {
            XCTAssertNoThrow(try catbird.send(action))
        }

        // Then
        XCTAssertEqual(requests.count, 3)
        XCTAssertEqual(requests, try actions.map { action in
            try action.makeRequest(to: url, parallelId: parallelId)
        })
    }

    @available(iOS 7, macOS 10.13, *)
    func testURLError() {
        // Given
        let connectionError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNetworkConnectionLost
        )
        Network.result = .failure(connectionError)

        // When
        XCTAssertThrowsError(try catbird.send(.removeAll)) { (error: Error) in
            // Then
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, connectionError.domain)
            XCTAssertEqual(nsError.code, connectionError.code)
        }
    }

    // MARK: - Private

    private func response(status: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}

#endif
