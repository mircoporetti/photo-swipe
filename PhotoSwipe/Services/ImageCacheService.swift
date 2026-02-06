import Foundation
import UIKit

protocol ImageCacheServiceProtocol: AnyObject {
    func getImage(for id: String) -> UIImage?
    func getThumbnail(for id: String) -> UIImage?
    func cacheImage(_ image: UIImage, for id: String)
    func cacheThumbnail(_ image: UIImage, for id: String)
    func removeImage(for id: String)
    func removeThumbnail(for id: String)
    func clearAll()
}

final class ImageCacheService: ImageCacheServiceProtocol {
    private var images: [String: UIImage] = [:]
    private var thumbnails: [String: UIImage] = [:]
    private let lock = NSLock()
    
    func getImage(for id: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return images[id]
    }
    
    func getThumbnail(for id: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return thumbnails[id]
    }
    
    func cacheImage(_ image: UIImage, for id: String) {
        lock.lock()
        defer { lock.unlock() }
        images[id] = image
    }
    
    func cacheThumbnail(_ image: UIImage, for id: String) {
        lock.lock()
        defer { lock.unlock() }
        thumbnails[id] = image
    }
    
    func removeImage(for id: String) {
        lock.lock()
        defer { lock.unlock() }
        images.removeValue(forKey: id)
    }
    
    func removeThumbnail(for id: String) {
        lock.lock()
        defer { lock.unlock() }
        thumbnails.removeValue(forKey: id)
    }
    
    func clearAll() {
        lock.lock()
        defer { lock.unlock() }
        images.removeAll()
        thumbnails.removeAll()
    }
}
