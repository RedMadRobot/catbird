import Foundation

/// Application configuration.
public struct AppConfiguration {

    /// Application work mode.
    public enum Mode: Equatable {
        case write(URL)
        case read
    }

    /// Application work mode.
    public let mode: Mode

    /// The directory for mocks.
    public let mocksDirectory: URL
}

extension AppConfiguration {

    /// Path to the source directory.
    public static var sourceDir: String {
        return #file.components(separatedBy: "/Sources")[0]
    }

    /// Detect application configuration.
    public static func detect(
        from enviroment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> AppConfiguration {

        let mocksDirectory = try { () throws -> URL in
            let path = enviroment["CATBIRD_MOCKS_DIR", default: sourceDir]
            guard let url = URL(string: path) else {
                fatalError("Invalid URL CATBIRD_MOCKS_DIR=\(path)")
            }
            return url
        }()

        if let path = enviroment["CATBIRD_PROXY_URL"], let url = URL(string: path) {
            return AppConfiguration(mode: .write(url), mocksDirectory: mocksDirectory)
        }
        return AppConfiguration(mode: .read, mocksDirectory: mocksDirectory)
    }
}
