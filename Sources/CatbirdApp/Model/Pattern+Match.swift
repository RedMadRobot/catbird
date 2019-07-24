import CatbirdAPI

extension Pattern {
    
    func match(_ someValue: String) -> Bool {
        let pattern = value
        switch kind {
        case .equal:
            return pattern == someValue
        case .glob:
            return Glob(pattern: pattern).check(someValue)
        case .regexp:
            return someValue.range(of: pattern , options: [.regularExpression, .caseInsensitive]) != nil
        }
    }
    
}
