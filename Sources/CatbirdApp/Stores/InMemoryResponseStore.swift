import CatbirdAPI
import Vapor
import NIO

final class InMemoryResponseStore: ResponseStore {
    private var _items: [ResponseStoreItem] = []
    private let _queue = DispatchQueue(label: "com.redmadrobot.catbird.InMemoryResponseStore")

    // MARK: - ResponseStore

    var items: [ResponseStoreItem] {
        _queue.sync { _items }
    }

    func response(for request: Request) -> EventLoopFuture<Response> {
        let item = _queue.sync { () -> ResponseStoreItem? in
            guard let index = _items.firstIndex(where: { $0.match(request) }) else {
                return nil
            }
            let item = _items[index].decremented()
            if !item.isValid {
                _items.remove(at: index)
            }
            return item
        }

        let response = item?.response ?? Response(status: .notFound)

        if let delay = item?.mock.delay {
            let deadline = NIODeadline.now() + TimeAmount.seconds(Int64(delay))
            return request.eventLoop.scheduleTask(deadline: deadline, { response }).futureResult
        }
        return request.eventLoop.makeSucceededFuture(response)
    }

    func perform(_ action: CatbirdAction, for request: Request) -> EventLoopFuture<Response> {
        let status = _queue.sync { () -> HTTPStatus in
            switch action {
            case .update(let pattern, let mock?):
                let item = ResponseStoreItem(pattern: pattern, mock: mock)
                if let index = _items.firstIndex(where: { $0.pattern == pattern })  {
                    _items[index] = item
                } else {
                    _items.append(item)
                }
                return .created
            case .update(let pattern, .none):
                _items.removeAll(where: { $0.pattern == pattern })
                return .noContent
            case .removeAll:
                _items.removeAll(keepingCapacity: true)
                return .noContent
            }
        }
        return request.eventLoop.makeSucceededFuture(Response(status: status))
    }

}
