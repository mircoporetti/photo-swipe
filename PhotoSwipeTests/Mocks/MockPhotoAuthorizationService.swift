import Foundation
import Photos
@testable import PhotoSwipe

final class MockPhotoAuthorizationService: PhotoAuthorizationServiceProtocol {
    var statusToReturn: PHAuthorizationStatus = .notDetermined
    var authorizationToGrant: PHAuthorizationStatus = .authorized
    var requestAuthorizationCalled = false
    
    var status: PHAuthorizationStatus {
        get async { statusToReturn }
    }
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        requestAuthorizationCalled = true
        return authorizationToGrant
    }
}
