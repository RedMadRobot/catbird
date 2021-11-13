import CatbirdAPI

struct PatternViewModel: Encodable {

    let id: Int
    let method: String
    let url: String
    let headers: [HeaderItemViewModel]
    let response: ResponseViewModel

    init(id: Int, request: RequestPattern, response: ResponseMock) {
        self.id = id
        method = request.method.rawValue
        url = request.url.value
        headers = request.headers.map { HeaderItemViewModel($0) }.sorted()
        self.response = ResponseViewModel(data: response)
    }
}
