public struct RequestBag: Codable, Equatable {
    public let pattern: RequestPattern
    public let data: ResponseData

    public init(pattern: RequestPattern, data: ResponseData) {
        self.pattern = pattern
        self.data = data
    }
}

public protocol RequestBagConvertible {
    var pattern: RequestPattern { get }
    var responseData: ResponseData { get }
}

public extension RequestBagConvertible {

    var requestBag: RequestBag {
        return RequestBag(pattern: pattern, data: responseData)
    }
}
