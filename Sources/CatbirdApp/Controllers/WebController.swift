import CatbirdAPI
import Vapor

/// Controls web view for show list of mocking requests
final class WebController: RouteCollection {
    
    private let store: BagsResponseStore
    
    init(store: BagsResponseStore) {
        self.store = store
    }
    
    func boot(router: Router) throws {
        let group = router.grouped("catbird")
        group.get("/", use: index)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        let vm = PageViewModel(bags: store.bags)
        return try req.view().render("index", vm)
    }
    
}
