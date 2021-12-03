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
        let parallelId = request.headers.first(name: CatbirdAction.parallelIdHeaderField)

        let status = _queue.sync { () -> HTTPStatus in
            switch action {
            case .update(var pattern, let mock):
                pattern.setParallelId(parallelId)
                let item = ResponseStoreItem(pattern: pattern, mock: mock)
                if let index = _items.firstIndex(where: { $0.pattern == pattern })  {
                    _items[index] = item
                } else {
                    _items.append(item)
                }
                return .created
            case .remove(var pattern):
                pattern.setParallelId(parallelId)
                _items.removeAll(where: { $0.pattern == pattern })
                return .noContent
            case .removeAll:
                _removeAll(parallelId: parallelId)
                return .noContent
            }
        }
        return request.eventLoop.makeSucceededFuture(Response(status: status))
    }

    // MARK: - Private

    private func _removeAll(parallelId: String?) {
        if let parallelId = parallelId {
            _items.removeAll(where: { item in
                item.pattern.headers[CatbirdAction.parallelIdHeaderField]?.match(parallelId) == true
            })
        } else {
            _items.removeAll(keepingCapacity: true)
        }
    }
}

extension RequestPattern {
    fileprivate mutating func setParallelId(_ parallelId: String?) {
        headers[CatbirdAction.parallelIdHeaderField] = parallelId.map(PatternMatch.equal)
    }
}
