import Foundation
import Photos
@testable import PhotoSwipe

final class MockDeleteQueueManager: DeleteQueueManagerProtocol {
    private(set) var queue: [PHAsset] = []
    
    var count: Int { queue.count }
    var isEmpty: Bool { queue.isEmpty }
    
    func add(_ asset: PHAsset) {
        queue.append(asset)
    }
    
    func remove(byId id: String) {
        queue.removeAll { $0.localIdentifier == id }
    }
    
    func contains(id: String) -> Bool {
        queue.contains { $0.localIdentifier == id }
    }
    
    func removeLast() -> PHAsset? {
        guard !queue.isEmpty else { return nil }
        return queue.removeLast()
    }
    
    func clear() {
        queue.removeAll()
    }
}
