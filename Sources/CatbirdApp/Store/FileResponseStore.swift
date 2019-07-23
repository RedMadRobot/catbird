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
        
        let patternPath: String
        if case .equal(let value) = pattern.url, let url = URL(string: value) {
            patternPath = url.path
        } else {
            patternPath = pattern.url.value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        }
        let url = URL(fileURLWithPath: path + patternPath, isDirectory: false)
        try createDirectories(for: url)
        try body.write(to: url)
    }

    func removeAllResponses() throws {}

    // MARK: - Private

    private func createDirectories(for url: URL) throws {
        // Remove file name
        let dirUrl = url.deletingLastPathComponent()
        try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true)
    }
}
