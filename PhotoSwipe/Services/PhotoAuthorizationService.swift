import Foundation
import Photos

protocol PhotoAuthorizationServiceProtocol {
    var status: PHAuthorizationStatus { get async }
    func requestAuthorization() async -> PHAuthorizationStatus
}

final class PhotoAuthorizationService: PhotoAuthorizationServiceProtocol {
    var status: PHAuthorizationStatus {
        get async {
            PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
    }
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
}
