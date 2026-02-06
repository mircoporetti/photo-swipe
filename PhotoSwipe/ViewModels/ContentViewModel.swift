import Foundation
import Photos
import UIKit

@MainActor
final class ContentViewModel: ObservableObject {
    @Published private(set) var photos: [PhotoModel] = []
    @Published private(set) var allPhotos: [PhotoModel] = []
    @Published private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published private(set) var isLoading = false
    @Published private(set) var keptPhotosCount = 0
    @Published var showingDeleteConfirmation = false
    @Published var errorMessage: String?
    
    private var keptPhotoIds: Set<String> = []
    
    private let authService: PhotoAuthorizationServiceProtocol
    private let repository: PhotoRepositoryProtocol
    private let deleteQueue: DeleteQueueManagerProtocol
    let imageCache: ImageCacheServiceProtocol
    
    var photosToDeleteCount: Int { deleteQueue.count }
    var hasPhotosToDelete: Bool { !deleteQueue.isEmpty }
    var totalReviewed: Int { deleteQueue.count + keptPhotosCount }
    var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }
    
    func decisionFor(_ photoId: String) -> SwipeAction? {
        if keptPhotoIds.contains(photoId) { return .keep }
        if deleteQueue.contains(id: photoId) { return .delete }
        return nil
    }
    
    var photosMarkedForDeletion: [PhotoModel] {
        let deleteIds = Set(deleteQueue.queue.map { $0.localIdentifier })
        return allPhotos.filter { deleteIds.contains($0.id) }
    }
    
    func restorePhoto(_ photo: PhotoModel) {
        deleteQueue.remove(byId: photo.id)
        keptPhotoIds.insert(photo.id)
        keptPhotosCount = keptPhotoIds.count
    }
    
    init(
        authService: PhotoAuthorizationServiceProtocol = PhotoAuthorizationService(),
        repository: PhotoRepositoryProtocol = PhotoRepository(),
        deleteQueue: DeleteQueueManagerProtocol = DeleteQueueManager(),
        imageCache: ImageCacheServiceProtocol = ImageCacheService()
    ) {
        self.authService = authService
        self.repository = repository
        self.deleteQueue = deleteQueue
        self.imageCache = imageCache
    }
    
    func checkAuthorizationStatus() async {
        authorizationStatus = await authService.status
        if isAuthorized {
            await loadPhotos()
        }
    }
    
    func requestAuthorization() async {
        authorizationStatus = await authService.requestAuthorization()
        if isAuthorized {
            await loadPhotos()
        }
    }
    
    func loadPhotos() async {
        isLoading = true
        let fetched = await repository.fetchPhotos()
        photos = fetched
        allPhotos = fetched
        isLoading = false
    }
    
    func loadImage(for photo: PhotoModel, targetSize: CGSize) async -> UIImage? {
        if let cached = imageCache.getImage(for: photo.id) {
            return cached
        }
        
        if let image = await repository.loadImage(for: photo, targetSize: targetSize) {
            imageCache.cacheImage(image, for: photo.id)
            return image
        }
        return nil
    }
    
    func loadThumbnail(for photo: PhotoModel) async -> UIImage? {
        if let cached = imageCache.getThumbnail(for: photo.id) {
            return cached
        }
        
        if let thumbnail = await repository.loadImage(for: photo, targetSize: AppConstants.Thumbnail.size) {
            imageCache.cacheThumbnail(thumbnail, for: photo.id)
            return thumbnail
        }
        return nil
    }
    
    func markForDeletion(_ photo: PhotoModel) {
        deleteQueue.add(photo.asset)
        keptPhotoIds.remove(photo.id)
        removeFromStack(photo)
    }
    
    func keepPhoto(_ photo: PhotoModel) {
        keptPhotoIds.insert(photo.id)
        deleteQueue.remove(byId: photo.id)
        keptPhotosCount = keptPhotoIds.count
        removeFromStack(photo)
    }
    
    func moveToFront(_ photo: PhotoModel) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            guard index != 0 else { return }
            let fromTapped = Array(photos[index...])
            let beforeTapped = Array(photos[..<index])
            photos = fromTapped + beforeTapped
        } else {
            keptPhotoIds.remove(photo.id)
            deleteQueue.remove(byId: photo.id)
            keptPhotosCount = keptPhotoIds.count
            photos.insert(photo, at: 0)
        }
    }
    
    private func removeFromStack(_ photo: PhotoModel) {
        imageCache.removeImage(for: photo.id)
        photos.removeAll { $0.id == photo.id }
    }
    
    func undoLastDelete() {
        guard let lastAsset = deleteQueue.removeLast() else { return }
        let photo = PhotoModel(id: lastAsset.localIdentifier, asset: lastAsset)
        photos.insert(photo, at: 0)
    }
    
    func executeDeletes() async {
        guard !deleteQueue.isEmpty else { return }
        
        let deletedIds = Set(deleteQueue.queue.map { $0.localIdentifier })
        
        do {
            try await repository.deletePhotos(deleteQueue.queue)
            deleteQueue.clear()
            
            allPhotos.removeAll { deletedIds.contains($0.id) }
            photos.removeAll { deletedIds.contains($0.id) }
            
            for id in deletedIds {
                keptPhotoIds.remove(id)
                imageCache.removeImage(for: id)
                imageCache.removeThumbnail(for: id)
            }
            keptPhotosCount = keptPhotoIds.count
            
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete photos: \(error.localizedDescription)"
        }
    }
    
    func reset() async {
        deleteQueue.clear()
        keptPhotoIds.removeAll()
        keptPhotosCount = 0
        imageCache.clearAll()
        allPhotos = []
        await loadPhotos()
    }
}
