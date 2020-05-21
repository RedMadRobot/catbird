import CatbirdAPI

struct ResponseViewModel: Encodable {

    let statusCode: Int
    let headers: [HeaderItemViewModel]
    let body: String?

    init(data: ResponseMock) {
        statusCode = data.status
        headers = data.headers.map { HeaderItemViewModel($0) }.sorted()
        if let bodyData = data.body, !bodyData.isEmpty {
            body = String(data: bodyData, encoding: .utf8) ?? "[Binary data]"
        } else {
            body = nil
        }
    }
}
