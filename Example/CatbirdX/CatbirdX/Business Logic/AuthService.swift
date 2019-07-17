//
//  AuthService.swift
//  CatbirdX
//
//  Created by Anton Glezman on 01/07/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

final class AuthService {
    
    let baseUrl: URL
    let session: URLSession
    
    init() {
        baseUrl = UserDefaults.standard.url(forKey: "url_key") ?? URL(string: "http://127.0.0.1:8080")!
        session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
    }
    
    func login(with email: String, password: String, completion: @escaping (Result<Void, Error>) -> ()) {
        var request = URLRequest(url: baseUrl.appendingPathComponent("login"))
        request.httpMethod = "POST"
        _ = dataTask(request) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func dataTask(_ urlRequest: URLRequest, completion: @escaping (Error?) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            switch (response, error) {
            case (_, let error?):
                completion(error)
            case (let http as HTTPURLResponse, _):
                completion(HttpError(response: http, data: data))
            default:
                completion(nil)
            }
        }
        task.resume()
        return task
    }
    
}


struct HttpError: Error {
    
    /// HTTP ststus code.
    public let errorCode: Int
    
    init?(response: HTTPURLResponse, data: Data?) {
        guard !(200..<300).contains(response.statusCode) else { return nil }
        self.errorCode = response.statusCode
    }
}
