import CatbirdAPI

extension Pattern {
    
    func match(_ someValue: String) -> Bool {
        switch self {
        case .equal(let pattern):
            return pattern == someValue
        case .glob(let pattern):
            return Glob(globPattern: pattern).check(someValue)
        case .regexp(let pattern):
            return someValue.range(of: pattern , options: [.regularExpression, .caseInsensitive]) != nil
        }
    }
    
}
