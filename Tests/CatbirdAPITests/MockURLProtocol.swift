import Foundation

final class MockURLProtocol: URLProtocol {

    /// All current requests.
    static var protocols: [URLProtocol] = []

    /// Request result.
    static var result = Result<URLResponse, Error>.failure(URLError(.unsupportedURL))

    static func clear() {
        protocols.removeAll()
        result = .failure(URLError(.unsupportedURL))
    }

    // MARK: - URLProtocol

    override class func canInit(with task: URLSessionTask) -> Bool {
        return true // catch all requests
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    private var _task: URLSessionTask
    override var task: URLSessionTask? { return _task }

    init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        _task = task
        super.init(request: task.originalRequest!, cachedResponse: cachedResponse, client: client)
    }

    override func startLoading() {
        MockURLProtocol.protocols.append(self)

        switch MockURLProtocol.result {
        case .success(let response):
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
