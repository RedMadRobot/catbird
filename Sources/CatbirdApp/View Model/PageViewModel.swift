import CatbirdAPI

struct PageViewModel: Encodable {

    let patterns: [PatternViewModel]

    init(items: [ResponseStoreItem]) {
        patterns = items.enumerated().map { id, item in
            PatternViewModel(id: id, request: item.pattern, response: item.mock)
        }
    }
}
