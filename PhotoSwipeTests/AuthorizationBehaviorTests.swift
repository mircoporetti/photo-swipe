import XCTest
import Photos
@testable import PhotoSwipe

@MainActor
final class AuthorizationBehaviorTests: XCTestCase {
    
    private var viewModel: ContentViewModel!
    private var mockAuthService: MockPhotoAuthorizationService!
    private var mockRepository: MockPhotoRepository!
    private var mockDeleteQueue: MockDeleteQueueManager!
    private var mockImageCache: MockImageCacheService!
    
    override func setUp() async throws {
        mockAuthService = MockPhotoAuthorizationService()
        mockRepository = MockPhotoRepository()
        mockDeleteQueue = MockDeleteQueueManager()
        mockImageCache = MockImageCacheService()
        
        viewModel = ContentViewModel(
            authService: mockAuthService,
            repository: mockRepository,
            deleteQueue: mockDeleteQueue,
            imageCache: mockImageCache
        )
    }
    
    func test_initialState_isNotDetermined() {
        XCTAssertEqual(viewModel.authorizationStatus, .notDetermined)
        XCTAssertFalse(viewModel.isAuthorized)
    }
    
    func test_whenAuthorized_loadsPhotos() async {
        mockAuthService.statusToReturn = .authorized
        
        await viewModel.checkAuthorizationStatus()
        
        XCTAssertEqual(viewModel.authorizationStatus, .authorized)
        XCTAssertTrue(viewModel.isAuthorized)
    }
    
    func test_whenLimited_stillAllowsAccess() async {
        mockAuthService.statusToReturn = .limited
        
        await viewModel.checkAuthorizationStatus()
        
        XCTAssertTrue(viewModel.isAuthorized)
    }
    
    func test_whenDenied_isNotAuthorized() async {
        mockAuthService.statusToReturn = .denied
        
        await viewModel.checkAuthorizationStatus()
        
        XCTAssertFalse(viewModel.isAuthorized)
    }
    
    func test_whenRestricted_isNotAuthorized() async {
        mockAuthService.statusToReturn = .restricted
        
        await viewModel.checkAuthorizationStatus()
        
        XCTAssertFalse(viewModel.isAuthorized)
    }
    
    func test_requestAuthorization_callsAuthService() async {
        mockAuthService.authorizationToGrant = .authorized
        
        await viewModel.requestAuthorization()
        
        XCTAssertTrue(mockAuthService.requestAuthorizationCalled)
    }
    
    func test_requestAuthorization_updatesStatus() async {
        mockAuthService.authorizationToGrant = .authorized
        
        await viewModel.requestAuthorization()
        
        XCTAssertEqual(viewModel.authorizationStatus, .authorized)
    }
    
    func test_requestAuthorization_whenGranted_loadsPhotos() async {
        mockAuthService.authorizationToGrant = .authorized
        
        await viewModel.requestAuthorization()
        
        XCTAssertTrue(viewModel.isAuthorized)
    }
    
    func test_requestAuthorization_whenDenied_doesNotLoadPhotos() async {
        mockAuthService.authorizationToGrant = .denied
        
        await viewModel.requestAuthorization()
        
        XCTAssertFalse(viewModel.isAuthorized)
        XCTAssertTrue(viewModel.photos.isEmpty)
    }
}
