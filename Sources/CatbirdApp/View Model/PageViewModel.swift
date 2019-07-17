import CatbirdAPI

struct PageViewModel: Encodable {
    
    let patterns: [PatternViewModel]
    
    init(bags: [RequestPattern : ResponseData]) {
        var patterns = [PatternViewModel]()
        for (index, bag) in bags.enumerated() {
            patterns.append(PatternViewModel(id: index, request: bag.key, response: bag.value))
        }
        self.patterns = patterns
    }
}
