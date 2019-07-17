import Vapor
import os.log

@available(OSX 10.12, *)
final class OSLogger: SystemLogger {
    private let log: OSLog

    init(subsystem: String, category: String) {
        self.log = OSLog(subsystem: subsystem, category: category)
    }

    // MARK: - Logger

    override func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        let type = osLogType(level)
        os_log("%{public}@", log: log, type: type, string as NSString)
    }

    // MARK: - Private

    private func osLogType(_ level: LogLevel) -> OSLogType {
        switch level {
        case .debug:
            return .debug
        case .info:
            return .info
        case .error, .warning:
            return .error
        case .fatal:
            return .fault
        case .verbose, .custom:
            return .default
        }
    }

}
