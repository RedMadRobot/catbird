import Logging

#if canImport(OSLogging)
import OSLogging
#endif

enum Loggers {
    static let inMemoryStore = logger(category: "InMemory")
    static let fileStore = logger(category: "File")

    private static func logger(category: String) -> Logging.Logger {
#if os(Linux)
        return Logging.Logger(label: CatbirdInfo.current.domain)
#else
        return Logging.Logger(label: CatbirdInfo.current.domain) {
            OSLogHandler(subsystem: $0, category: category)
        }
#endif
    }

}
