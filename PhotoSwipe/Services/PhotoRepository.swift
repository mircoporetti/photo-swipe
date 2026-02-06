import Foundation
import Photos
import UIKit

protocol PhotoRepositoryProtocol {
    func fetchPhotos() async -> [PhotoModel]
    func loadImage(for photo: PhotoModel, targetSize: CGSize) async -> UIImage?
    func deletePhotos(_ assets: [PHAsset]) async throws
}

final class PhotoRepository: PhotoRepositoryProtocol {
    private let imageManager = PHCachingImageManager()
    
    func fetchPhotos() async -> [PhotoModel] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        
        let results = PHAsset.fetchAssets(with: fetchOptions)
        
        var photos: [PhotoModel] = []
        results.enumerateObjects { asset, _, _ in
            let photo = PhotoModel(id: asset.localIdentifier, asset: asset)
            photos.append(photo)
        }
        
        return photos
    }
    
    func loadImage(for photo: PhotoModel, targetSize: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            imageManager.requestImage(
                for: photo.asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    func deletePhotos(_ assets: [PHAsset]) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }
    }
}
