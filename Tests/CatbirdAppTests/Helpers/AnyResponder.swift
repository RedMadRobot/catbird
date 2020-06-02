import Vapor

struct AnyResponder: Responder {
    let handler: (Request) -> EventLoopFuture<Response>

    func respond(to request: Request) -> EventLoopFuture<Response> {
        handler(request)
    }
}
