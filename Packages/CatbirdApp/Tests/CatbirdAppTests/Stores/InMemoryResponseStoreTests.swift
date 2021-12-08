import CatbirdAPI
@testable import CatbirdApp
import Vapor
import XCTest

final class InMemoryResponseStoreTests: RequestTestCase {

    private var store: InMemoryResponseStore!
    private var parallelId: String { name }

    override func setUp() {
        super.setUp()
        store = InMemoryResponseStore()
        XCTAssertEqual(store.items, [])
    }

    private func perform(_ action: CatbirdAction, parallelId: String? = nil, file: StaticString = #file, line: UInt = #line) {
        let request = makeRequest()
        if let parallelId = parallelId {
            request.headers.add(name: "X-Catbird-Parallel-Id", value: parallelId)
        }
        let future = store.perform(action, for: request)
        XCTAssertEqual(try future.wait().status, action.expectedStatus, file: file, line: line)
    }

    // MARK: - perform CatbirdAction

    func testPerformAdd() throws {
        // Given
        let mocks = BookMock.mocks

        // When
        mocks.forEach { perform(.add($0)) }

        // Then
        XCTAssertEqual(store.items.count, 4)
        XCTAssertEqual(store.items, mocks.map(\.item))
    }

    func testPerformAddWithParallelId() throws {
        // Given
        let mocks = BookMock.mocks
        mocks.forEach { perform(.add($0)) }
        var items = BookMock.mocks.map(\.item)

        // When
        let createA = BookMock.create(name: "A")
        perform(.add(createA), parallelId: parallelId)
        items.append(createA.item(parallelId: parallelId))

        // Then
        XCTAssertEqual(store.items.count, 5)
        XCTAssertEqual(store.items, items)
    }

    func testPerformUpdate() {
        // Given
        let createA = BookMock.create(name: "A")
        let createB = BookMock.create(name: "B")
        perform(.add(createB))

        // When
        perform(.add(createA))

        // Then
        XCTAssertEqual(store.items, [createA.item])
    }

    func testPerformUpdateWithParallelId() {
        // Given
        let createA = BookMock.create(name: "A")
        let createB = BookMock.create(name: "B")
        perform(.add(createA))
        perform(.add(createB), parallelId: parallelId)


        // When
        perform(.add(createA), parallelId: parallelId)

        // Then
        XCTAssertEqual(store.items, [
            createA.item,
            createA.item(parallelId: name)
        ])
    }

    func testPerformRemove() {
        // Given
        let first = BookMock.first
        let second = BookMock.second
        perform(.add(first))
        perform(.add(second))

        // When
        perform(.remove(first))

        // Then
        XCTAssertEqual(store.items, [second.item])
    }

    func testPerformRemoveWithParallelId() {
        // Given
        let first = BookMock.first
        perform(.add(first))
        perform(.add(first), parallelId: parallelId)

        // When
        perform(.remove(first), parallelId: parallelId)

        // Then
        XCTAssertEqual(store.items, [first.item])
    }

    func testPerformRemoveAll() {
        // Given
        BookMock.mocks.forEach { perform(.add($0)) }
        perform(.add(BookMock.create(name: "Z")), parallelId: parallelId)

        // When
        perform(.removeAll)

        // Then
        XCTAssertEqual(store.items, [])
    }

    func testPerformRemoveAllWithParallelId() {
        // Given
        BookMock.mocks.forEach { perform(.add($0)) }
        perform(.add(BookMock.create(name: "1")), parallelId: parallelId)
        perform(.add(BookMock.create(name: "2")), parallelId: parallelId)

        // When
        perform(.removeAll, parallelId: parallelId)

        // Then
        XCTAssertEqual(store.items.count, BookMock.mocks.count)
    }

    // MARK: - Response for Request

    func testResponseForRequest() throws {
        // Given
        BookMock.mocks.forEach { perform(.add($0)) }

        // When
        request.method = .GET
        request.url = "/api/books/1"
        let response = try store.response(for: request).wait()

        // Then
        XCTAssertEqual(response.status.code, 200)
        XCTAssertEqual(response.body.string, "first book")
    }

    func testNotFoundResponse() throws {
        // Given
        BookMock.mocks.forEach { perform(.add($0)) }

        // When
        request.method = .GET
        request.url = "/api/books/4"
        let response = try store.response(for: request).wait()

        // Then
        XCTAssertEqual(response.status.code, 404)
        XCTAssertNil(response.body.string)
    }

    func testResponseLimit() throws {
        // Given
        BookMock.mocks.forEach { perform(.add($0)) }

        // When
        request.method = .GET
        request.url = "/api/books/2"
        XCTAssertEqual(try store.response(for: request).wait().status.code, 200)
        XCTAssertEqual(try store.response(for: request).wait().status.code, 200)
        let response = try store.response(for: request).wait()

        // Then
        XCTAssertEqual(response.status.code, 404)
        XCTAssertNil(response.body.string)
    }

    func testResponseDelay() throws {
        // Given
        let mock = BookMock.heavy(delay: 2)
        perform(.add(mock))
        let start = Date()

        // When
        request.method = .GET
        request.url = "/api/books/1000"
        let response = try store.response(for: request).wait()

        // Then
        XCTAssertEqual(Date().timeIntervalSince(start), 2, accuracy: 0.5)
        XCTAssertEqual(response.status.code, 200)
        XCTAssertEqual(response.body.string, "heavy book")
    }
}
