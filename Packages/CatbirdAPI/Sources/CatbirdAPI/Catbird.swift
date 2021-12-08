import Foundation

/// API Client to mock server.
public final class Catbird {

    /// Localhost IPv4 representation.
    public static let localhost = URL(string: "http://127.0.0.1:8080")!

    /// Default network session.
    public static var session: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        session.sessionDescription = "Catbird session"
        return session
    }

    /// Server adress.
    public let url: URL

    /// Network session.
    private let session: URLSession

    /// Unique catbird id for parallel test running.
    public var parallelId: String?

    public init(url: URL = localhost, session: URLSession = session, parallelId: String? = nil) {
        self.url = url
        self.session = session
        self.parallelId = parallelId
    }

    // MARK: - Public

    /// Send the command on the server.
    ///
    /// - Parameters:
    ///   - command: Catbird API action.
    ///   - completion: A closure with the result of the command.
    /// - Returns: Session task.
    @discardableResult
    public func send(_ action: CatbirdAction, completion: @escaping (Error?) -> Void) -> URLSessionTask {
        let request = try! action.makeRequest(to: url, parallelId: parallelId)
        return dataTask(request, completion: completion)
    }

    /// Send the command synchronously on the server.
    ///
    /// - Warning: Only for testsing.
    /// - Note: Use `URLSessionConfiguration.timeoutIntervalForRequest` for timeout.
    /// - Parameter action: Catbird API action.
    /// - Throws: `URLError` or `CatbirdError`.
    public func send(_ action: CatbirdAction) throws {
        var outError: Error?
        
        let task = send(action, completion: { (error: Error?) in
            outError = error
        })

        task.wait()

        if let error = outError {
            throw error
        }
    }

    // MARK: - Private

    private func dataTask(_ urlRequest: URLRequest, completion: @escaping (Error?) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            switch (response, error) {
            case (_, let error?):
                completion(error)
            case (let http as HTTPURLResponse, _):
                completion(CatbirdError(response: http, data: data))
            default:
                completion(nil)
            }
        }
        task.resume()
        return task
    }

}
