import XCTest
import Photos
@testable import PhotoSwipe

@MainActor
final class DeleteQueueBehaviorTests: XCTestCase {

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

        mockRepository.photosToReturn = [
            makeTestPhoto(id: "photo-1"),
            makeTestPhoto(id: "photo-2"),
            makeTestPhoto(id: "photo-3")
        ]

        viewModel = ContentViewModel(
            authService: mockAuthService,
            repository: mockRepository,
            deleteQueue: mockDeleteQueue,
            imageCache: mockImageCache
        )
    }

    func test_initialState_hasEmptyDeleteQueue() {
        XCTAssertEqual(viewModel.photosToDeleteCount, 0)
        XCTAssertFalse(viewModel.hasPhotosToDelete)
    }

    func test_hasPhotosToDelete_isTrueWhenQueueNotEmpty() async {
        mockAuthService.statusToReturn = .authorized
        await viewModel.checkAuthorizationStatus()

        let photo = viewModel.photos.first!
        viewModel.markForDeletion(photo)

        XCTAssertTrue(viewModel.hasPhotosToDelete)
    }

    func test_executeDeletes_clearsQueueOnSuccess() async {
        mockRepository.deleteError = nil
        await viewModel.executeDeletes()
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_executeDeletes_setsErrorMessageOnFailure() async {
        mockRepository.deleteError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied"])
        mockAuthService.statusToReturn = .authorized
        await viewModel.checkAuthorizationStatus()

        let photo = viewModel.photos.first!
        viewModel.markForDeletion(photo)
        await viewModel.executeDeletes()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Permission denied") ?? false)
    }

    func test_reset_clearsDeleteQueue() async {
        mockAuthService.statusToReturn = .authorized
        await viewModel.checkAuthorizationStatus()

        let photo = viewModel.photos.first!
        viewModel.markForDeletion(photo)

        await viewModel.reset()

        XCTAssertEqual(viewModel.photosToDeleteCount, 0)
    }

    func test_reset_clearsKeptCount() async {
        mockAuthService.statusToReturn = .authorized
        await viewModel.checkAuthorizationStatus()

        let photo = viewModel.photos.first!
        viewModel.keepPhoto(photo)

        await viewModel.reset()

        XCTAssertEqual(viewModel.keptPhotosCount, 0)
    }

    func test_reset_clearsImageCache() async {
        await viewModel.reset()
        XCTAssertTrue(mockImageCache.clearAllCalled)
    }
}
