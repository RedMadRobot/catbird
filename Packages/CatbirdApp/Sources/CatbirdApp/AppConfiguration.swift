import Vapor

/// Application configuration.
public struct AppConfiguration {

    public let isRecordMode: Bool

    public let proxyEnabled: Bool

    /// The directory for mocks.
    public let mocksDirectory: URL

    public let redirectUrl: URL?

    public let maxBodySize: String
}

extension AppConfiguration {

    /// Path to the source directory.
    public static var sourceDir: String {
        return #file.components(separatedBy: "/Sources")[0]
    }

    /// Detect application configuration.
    public static func detect(
        from environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> AppConfiguration {

        let mocksDirectory = try { () throws -> URL in
            let path = environment["CATBIRD_MOCKS_DIR", default: sourceDir]
            guard let url = URL(string: path) else {
                fatalError("Invalid URL CATBIRD_MOCKS_DIR=\(path)")
            }
            return url
        }()

        let isRecordMode = environment["CATBIRD_RECORD_MODE"].flatMap { NSString(string: $0).boolValue } ?? false
        let proxyEnabled = environment["CATBIRD_PROXY_ENABLED"].flatMap { NSString(string: $0).boolValue } ?? false
        let redirectUrl = environment["CATBIRD_REDIRECT_URL"].flatMap { URL(string: $0) }
        let maxBodySize = environment["CATBIRD_MAX_BODY_SIZE", default: "50mb"]

        return AppConfiguration(
            isRecordMode: isRecordMode,
            proxyEnabled: proxyEnabled,
            mocksDirectory: mocksDirectory,
            redirectUrl: redirectUrl,
            maxBodySize: maxBodySize)
    }
}
