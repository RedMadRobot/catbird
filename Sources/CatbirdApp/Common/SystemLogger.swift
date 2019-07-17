import Vapor

class SystemLogger: Logger, Service {
    private static let subsystem = "com.redmadrobot.catbird"

    static let `default`: SystemLogger = category("Catbird")

    static func category(_ category: String) -> SystemLogger {
        if #available(OSX 10.12, *) {
            return OSLogger(subsystem: subsystem, category: category)
        } else {
            fatalError()
        }
    }

    // MARK: - Logger

    func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        fatalError()
    }
}
