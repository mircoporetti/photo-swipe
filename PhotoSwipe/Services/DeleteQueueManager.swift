import Foundation
import Photos

protocol DeleteQueueManagerProtocol {
    var queue: [PHAsset] { get }
    var count: Int { get }
    var isEmpty: Bool { get }
    
    func add(_ asset: PHAsset)
    func remove(byId id: String)
    func contains(id: String) -> Bool
    func removeLast() -> PHAsset?
    func clear()
}

final class DeleteQueueManager: DeleteQueueManagerProtocol {
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
