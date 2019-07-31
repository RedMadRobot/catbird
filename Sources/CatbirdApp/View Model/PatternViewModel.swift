import CatbirdAPI

struct PatternViewModel: Encodable {
    
    let id: Int
    let method: String
    let url: String
    let headers: [HeaderItemViewModel]
    let response: ResponseViewModel
    
    init(id: Int, request: RequestPattern, response: ResponseData) {
        self.id = id
        method = request.method
        url = request.url.value
        headers = request.headerFields.map { HeaderItemViewModel($0) }.sorted()
        self.response = ResponseViewModel(data: response)
    }
}
