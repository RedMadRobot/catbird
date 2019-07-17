//
//  AppConfig.swift
//  App
//
//  Created by Alexander Ignatev on 30/05/2019.
//

import Foundation

/// Application work mode.
enum AppMode: Equatable {
    case write(URL)
    case read
}

/// Application configuration.
struct AppConfig {

    /// Application work mode.
    let mode: AppMode

    /// The directory for mocks.
    let mocksDirectory: String

}

extension AppConfig {

    /// Path to the source directory.
    static var sourceDir: String {
        return #file.components(separatedBy: "/Sources")[0]
    }

    /// Detect application configuration.
    static func detect(
        from enviroment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> AppConfig {

        let mocksDir = enviroment["CATBIRD_MOCKS_DIR", default: sourceDir + "/Mocks"]

        if let path = enviroment["CATBIRD_PROXY_URL"], let url = URL(string: path) {
            return AppConfig(mode: .write(url), mocksDirectory: mocksDir)
        }
        return AppConfig(mode: .read, mocksDirectory: mocksDir)
    }
}
