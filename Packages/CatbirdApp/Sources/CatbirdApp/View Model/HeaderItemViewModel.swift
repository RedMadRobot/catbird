import CatbirdAPI

struct HeaderItemViewModel: Encodable, Comparable {
    
    let key: String
    let value: String
    
    init(_ item: Dictionary<String, PatternMatch>.Element) {
        key = item.key
        value = item.value.value
    }
    
    init(_ item: Dictionary<String, String>.Element) {
        key = item.key
        value = item.value
    }
    
    static func < (lhs: HeaderItemViewModel, rhs: HeaderItemViewModel) -> Bool {
        return lhs.key < rhs.key
    }
}
