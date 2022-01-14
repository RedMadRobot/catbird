import Logging

enum Loggers {
    static let inMemoryStore = logger(category: "InMemory")
    static let fileStore = logger(category: "File")

    private static func logger(category: String) -> Logging.Logger {
        Logging.Logger(label: CatbirdInfo.current.domain)
    }
}
