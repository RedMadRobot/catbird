import CatbirdAPI

struct PageViewModel: Encodable {
    
    let patterns: [PatternViewModel]
    
    init(bags: [RequestBag]) {
        var patterns = [PatternViewModel]()
        for (index, bag) in bags.enumerated() {
            patterns.append(PatternViewModel(id: index, request: bag.pattern, response: bag.data))
        }
        self.patterns = patterns
    }
}
