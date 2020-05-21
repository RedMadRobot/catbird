import CatbirdAPI
import Vapor

protocol ResponseStore {
    /// The internal representation for web page.
    var items: [ResponseStoreItem] { get }

    /// Request from the application under test.
    ///
    /// - Parameter request: HTTP request.
    func response(for request: Request) -> EventLoopFuture<Response>

    /// Action from tests.
    ///
    /// - Parameters:
    ///   - action: Catbird API action.
    ///   - request: HTTP request.
    func perform(_ action: CatbirdAction, for request: Request) -> EventLoopFuture<Response>
}
