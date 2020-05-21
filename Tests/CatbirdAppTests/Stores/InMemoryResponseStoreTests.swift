import CatbirdAPI
@testable import CatbirdApp
import Vapor
import XCTest

final class InMemoryResponseStoreTests: RequestTestCase {

    private var store: InMemoryResponseStore!

    override func setUp() {
        super.setUp()
        store = InMemoryResponseStore()
        XCTAssertEqual(store.items, [])
    }

    private func perform(_ action: CatbirdAction, file: StaticString = #file, line: UInt = #line) {
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

    func testPerformUpdate() {
        // Given
        let createA = BookMock.create("A")
        let createB = BookMock.create("B")
        perform(.add(createB))

        // When
        perform(.add(createA))

        // Then
        XCTAssertEqual(store.items, [createA.item])
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

    func testPerformRemoveAll() {
        // Given
        BookMock.mocks.forEach { perform(.add($0)) }

        // When
        perform(.removeAll)

        // Then
        XCTAssertEqual(store.items, [])
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

}
