import XCTest
import UIKit
@testable import PhotoSwipe

final class ImageCacheBehaviorTests: XCTestCase {
    
    private var cacheService: ImageCacheService!
    
    override func setUp() {
        cacheService = ImageCacheService()
    }
    
    func test_cacheImage_storesImage() {
        let image = UIImage()
        let photoId = "test-photo-1"
        
        cacheService.cacheImage(image, for: photoId)
        
        XCTAssertNotNil(cacheService.getImage(for: photoId))
    }
    
    func test_getImage_returnsNilForUncachedPhoto() {
        XCTAssertNil(cacheService.getImage(for: "nonexistent"))
    }
    
    func test_removeImage_clearsFromCache() {
        let image = UIImage()
        let photoId = "test-photo-1"
        
        cacheService.cacheImage(image, for: photoId)
        cacheService.removeImage(for: photoId)
        
        XCTAssertNil(cacheService.getImage(for: photoId))
    }
    
    func test_cacheThumbnail_storesThumbnail() {
        let thumbnail = UIImage()
        let photoId = "test-photo-1"
        
        cacheService.cacheThumbnail(thumbnail, for: photoId)
        
        XCTAssertNotNil(cacheService.getThumbnail(for: photoId))
    }
    
    func test_removeThumbnail_clearsFromCache() {
        let thumbnail = UIImage()
        let photoId = "test-photo-1"
        
        cacheService.cacheThumbnail(thumbnail, for: photoId)
        cacheService.removeThumbnail(for: photoId)
        
        XCTAssertNil(cacheService.getThumbnail(for: photoId))
    }
    
    func test_clearAll_removesAllCachedData() {
        cacheService.cacheImage(UIImage(), for: "photo-1")
        cacheService.cacheImage(UIImage(), for: "photo-2")
        cacheService.cacheThumbnail(UIImage(), for: "photo-1")
        
        cacheService.clearAll()
        
        XCTAssertNil(cacheService.getImage(for: "photo-1"))
        XCTAssertNil(cacheService.getImage(for: "photo-2"))
        XCTAssertNil(cacheService.getThumbnail(for: "photo-1"))
    }
    
    func test_imageAndThumbnail_areCachedIndependently() {
        let photoId = "test-photo-1"
        let fullImage = UIImage()
        let thumbnail = UIImage()
        
        cacheService.cacheImage(fullImage, for: photoId)
        cacheService.cacheThumbnail(thumbnail, for: photoId)
        
        cacheService.removeImage(for: photoId)
        
        XCTAssertNil(cacheService.getImage(for: photoId))
        XCTAssertNotNil(cacheService.getThumbnail(for: photoId))
    }
}
