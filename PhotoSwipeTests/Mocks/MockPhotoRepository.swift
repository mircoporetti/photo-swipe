import Foundation
import Photos
import UIKit
@testable import PhotoSwipe

final class MockPhotoRepository: PhotoRepositoryProtocol {
    var photosToReturn: [PhotoModel] = []
    var imageToReturn: UIImage? = nil
    var deleteError: Error? = nil
    var deletedAssets: [PHAsset] = []
    
    func fetchPhotos() async -> [PhotoModel] {
        return photosToReturn
    }
    
    func loadImage(for photo: PhotoModel, targetSize: CGSize) async -> UIImage? {
        return imageToReturn
    }
    
    func deletePhotos(_ assets: [PHAsset]) async throws {
        if let error = deleteError {
            throw error
        }
        deletedAssets = assets
    }
}
