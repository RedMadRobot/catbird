import Vapor

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

        let maxBodySize = environment["CATBIRD_MAX_BODY_SIZE", default: "50mb"]

        if let path = environment["CATBIRD_PROXY_URL"], let url = URL(string: path) {
            return AppConfiguration(mode: .write(url), mocksDirectory: mocksDirectory, maxBodySize: maxBodySize)
        }
        return AppConfiguration(mode: .read, mocksDirectory: mocksDirectory, maxBodySize: maxBodySize)
    }
}

struct Config {
    @AppEnv("CATBIRD_RECORDING_ON")
    var recordingMode: Bool = false

    @AppEnv("CATBIRD_PROXY")
    var proxyEnabled: Bool = false

    @AppEnv("CATBIRD_MOCKS_DIR", transform: { URL(string: $0) })
    var mocksDirectory: URL? = nil

    @AppEnv("CATBIRD_REDIRECT_URL", transform: { URL(string: $0) })
    var redirectUrl: URL? = nil

    @AppEnv("CATBIRD_MAX_BODY_SIZE", transform: { ByteCount(stringLiteral: $0) })
    var maxBodySize: ByteCount = "50mb"
}

/// Application env variable.
@propertyWrapper
struct AppEnv<Value> {
    let wrappedValue: Value

    /// A new application env variable.
    ///
    /// - Parameters:
    ///   - wrappedValue: Default value.
    ///   - key: Env variable name.
    ///   - transform: Transform env variable string if present.
    init(wrappedValue: Value, _ key: String, transform: (String) -> Value?) {
        self.wrappedValue = ProcessInfo.processInfo.environment[key].flatMap(transform) ?? wrappedValue
    }
}

extension AppEnv where Value == String {
    init(wrappedValue: String, _ key: String) {
        self.init(wrappedValue: wrappedValue, key, transform: { (value: String) -> String? in
            return value
        })
    }
}

extension AppEnv where Value == Bool {
    init(wrappedValue: Bool, _ key: String) {
        self.init(wrappedValue: wrappedValue, key, transform: { (value: String) -> Bool? in
            let string = value.lowercased()
            return string == "1" || string == "yes" || string == "true"
        })
    }
}
