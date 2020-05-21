import CatbirdAPI
@testable import CatbirdApp
import Foundation

enum BookMock: CatbirdMockConvertible {
    case books
    case create(String)
    case first
    case second

    static let mocks: [BookMock] = [
        .books,
        .create("3"),
        .first,
        .second
    ]

    var pattern: RequestPattern {
        switch self {
        case .books:
            return RequestPattern(method: .GET, url: "/api/books")
        case .create:
            return RequestPattern(method: .POST, url: "/api/books")
        case .first:
            return RequestPattern(method: .GET, url: "/api/books/1")
        case .second:
            return RequestPattern(method: .GET, url: "/api/books/2")
        }
    }

    var response: ResponseMock {
        switch self {
        case .books:
            return ResponseMock(status: 200, body: Data("all books".utf8))
        case .create(let name):
            return ResponseMock(status: 201, body: Data("new book: \(name)".utf8))
        case .first:
            return ResponseMock(status: 200, body: Data("first book".utf8))
        case .second:
            return ResponseMock(status: 200, body: Data("second book".utf8), limit: 2)
        }
    }

    var item: ResponseStoreItem {
        ResponseStoreItem(pattern: pattern, mock: response)
    }
}
