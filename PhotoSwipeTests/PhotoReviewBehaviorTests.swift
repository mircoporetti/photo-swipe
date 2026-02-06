import XCTest
import Photos
@testable import PhotoSwipe

@MainActor
final class PhotoReviewBehaviorTests: XCTestCase {

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

        mockAuthService.statusToReturn = .authorized
        await viewModel.checkAuthorizationStatus()
    }

    func test_keepingPhoto_incrementsKeptCount() {
        let photo = viewModel.photos.first!
        viewModel.keepPhoto(photo)
        XCTAssertEqual(viewModel.keptPhotosCount, 1)
    }

    func test_keepingPhoto_removesItFromReviewStack() {
        let initialCount = viewModel.photos.count
        let photo = viewModel.photos.first!

        viewModel.keepPhoto(photo)

        XCTAssertEqual(viewModel.photos.count, initialCount - 1)
        XCTAssertFalse(viewModel.photos.contains(photo))
    }

    func test_markingForDeletion_addsToDeleteQueue() {
        let photo = viewModel.photos.first!
        viewModel.markForDeletion(photo)
        XCTAssertEqual(viewModel.photosToDeleteCount, 1)
    }

    func test_markingForDeletion_removesFromReviewStack() {
        let photo = viewModel.photos.first!
        viewModel.markForDeletion(photo)
        XCTAssertFalse(viewModel.photos.contains(photo))
    }

    func test_undoLastDelete_restoresPhotoToStack() {
        let photo = viewModel.photos.first!
        viewModel.markForDeletion(photo)
        let countAfterDelete = viewModel.photos.count

        viewModel.undoLastDelete()

        XCTAssertEqual(viewModel.photos.count, countAfterDelete + 1)
        XCTAssertEqual(viewModel.photos.first?.id, photo.id)
    }

    func test_undoLastDelete_removesFromDeleteQueue() {
        let photo = viewModel.photos.first!
        viewModel.markForDeletion(photo)

        viewModel.undoLastDelete()

        XCTAssertEqual(viewModel.photosToDeleteCount, 0)
    }

    func test_undoWithEmptyQueue_doesNothing() {
        let initialPhotoCount = viewModel.photos.count
        viewModel.undoLastDelete()
        XCTAssertEqual(viewModel.photos.count, initialPhotoCount)
    }

    func test_totalReviewed_countsKeptAndDeleted() {
        XCTAssertEqual(viewModel.totalReviewed, 0)

        let photo1 = viewModel.photos[0]
        viewModel.keepPhoto(photo1)

        let photo2 = viewModel.photos[0]
        viewModel.markForDeletion(photo2)

        XCTAssertEqual(viewModel.totalReviewed, viewModel.keptPhotosCount + viewModel.photosToDeleteCount)
    }
}
