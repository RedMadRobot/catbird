import CatbirdAPI
import Vapor

final class FileResponseStore: ResponseStore {

    /// The directory for response files.
    private let path: String

    private let fileManager: FileManager

    init(path: String, fileManager: FileManager = .default) {
        self.path = path
        self.fileManager = fileManager
    }

    // MARK: - ResponseStore

    func response(for request: Request) throws -> Response {
        let url = URL(fileURLWithPath: path + request.http.url.path, isDirectory: false)
        let data = try Data(contentsOf: url)
        return request.response(data)
    }

    func setResponse(data: ResponseData?, for pattern: RequestPattern) throws {
        guard let body = data?.body else { return }

        let url = URL(fileURLWithPath: path + pattern.url.path, isDirectory: false)
        try createDirectories(for: pattern.url)
        try body.write(to: url)
    }

    func removeAllResponses() throws {}

    // MARK: - Private

    private func createDirectories(for url: URL) throws {
        // Remove first component "/" and last with file name
        let pathComponents = url.pathComponents.dropFirst().dropLast()
        guard !pathComponents.isEmpty else { return }

        try pathComponents
            .indices
            .map { pathComponents[...$0].joined(separator: "/") }
            .map { "\(path)/\($0)" }
            .filter { !fileManager.fileExists(atPath: $0, isDirectory: nil) }
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
            .forEach { try fileManager.createDirectory(at: $0, withIntermediateDirectories: true) }
    }
}
