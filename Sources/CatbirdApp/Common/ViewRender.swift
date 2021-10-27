import Stencil
import PathKit
import Vapor

final class HTMLRender {
    private let environment: Stencil.Environment
    private let allocator: ByteBufferAllocator

    init(viewsDirectory: String, allocator: ByteBufferAllocator) {
        let loader = FileSystemLoader(paths: [Path(viewsDirectory)])
        self.environment = Environment(loader: loader)
        self.allocator = allocator
    }

    func render(_ name: String, _ context: [String: Any]) throws -> View {
        let string = try environment.renderTemplate(name: name, context: context)
        var buffer = allocator.buffer(capacity: string.utf8.count)
        buffer.writeString(string)
        return View(data: buffer)
    }
}
