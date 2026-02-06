import Foundation
import UIKit
@testable import PhotoSwipe

final class MockImageCacheService: ImageCacheServiceProtocol {
    private var images: [String: UIImage] = [:]
    private var thumbnails: [String: UIImage] = [:]
    var clearAllCalled = false
    
    func getImage(for id: String) -> UIImage? {
        images[id]
    }
    
    func getThumbnail(for id: String) -> UIImage? {
        thumbnails[id]
    }
    
    func cacheImage(_ image: UIImage, for id: String) {
        images[id] = image
    }
    
    func cacheThumbnail(_ image: UIImage, for id: String) {
        thumbnails[id] = image
    }
    
    func removeImage(for id: String) {
        images.removeValue(forKey: id)
    }
    
    func removeThumbnail(for id: String) {
        thumbnails.removeValue(forKey: id)
    }
    
    func clearAll() {
        clearAllCalled = true
        images.removeAll()
        thumbnails.removeAll()
    }
}
