import Foundation

/// From `Vapor.ErrorMiddleware`.
private struct ErrorResponse: Codable {

    /// Always `true` to indicate this is a non-typical JSON response.
    let error: Bool

    /// The reason for the error.
    let reason: String
}

public struct CatbirdError: LocalizedError, CustomNSError {

    /// The domain of the error.
    public static var errorDomain = "com.redmadrobot.catbird.APIErrorDomain"

    /// HTTP status code.
    public let errorCode: Int

    /// A localized message describing the reason for the failure.
    public let failureReason: String?

    init?(statusCode: Int, data: Data?) {
        guard !(200..<300).contains(statusCode) else { return nil }
        self.errorCode = statusCode
        self.failureReason = data.flatMap { (body: Data) in
            try? JSONDecoder().decode(ErrorResponse.self, from: body).reason
        }
    }

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
#if !os(Linux)
        return HTTPURLResponse.localizedString(forStatusCode: errorCode)
#else
        return "Status code: \(errorCode)"
#endif
    }

    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        return userInfo
    }

}
