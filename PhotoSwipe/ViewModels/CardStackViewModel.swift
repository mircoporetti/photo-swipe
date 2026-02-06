import Foundation
import SwiftUI
import UIKit

@MainActor
final class CardStackViewModel: ObservableObject {
    @Published var currentOffset: CGSize = .zero
    @Published var currentRotation: Double = 0
    @Published var loadedImages: [String: UIImage] = [:]
    @Published var loadedThumbnails: [String: UIImage] = [:]
    
    private weak var contentViewModel: ContentViewModel?
    
    init(contentViewModel: ContentViewModel? = nil) {
        self.contentViewModel = contentViewModel
    }
    
    func setContentViewModel(_ viewModel: ContentViewModel) {
        self.contentViewModel = viewModel
    }
    
    func handleSwipeChange(_ translation: CGSize) {
        currentOffset = translation
        currentRotation = Double(translation.width / 20)
    }
    
    func handleSwipeEnd(_ translation: CGSize, photo: PhotoModel) {
        if translation.width > AppConstants.Swipe.threshold {
            swipeRight(photo: photo)
        } else if translation.width < -AppConstants.Swipe.threshold {
            swipeLeft(photo: photo)
        } else {
            resetPosition()
        }
    }
    
    private func swipeRight(photo: PhotoModel) {
        withAnimation(.easeOut(duration: AppConstants.Swipe.animationDuration)) {
            currentOffset = CGSize(width: AppConstants.Swipe.offscreenOffset, height: 0)
            currentRotation = AppConstants.Swipe.maxRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Swipe.animationDuration) { [weak self] in
            self?.contentViewModel?.keepPhoto(photo)
            self?.cleanupPhoto(photo)
            self?.resetPosition()
        }
    }
    
    private func swipeLeft(photo: PhotoModel) {
        withAnimation(.easeOut(duration: AppConstants.Swipe.animationDuration)) {
            currentOffset = CGSize(width: -AppConstants.Swipe.offscreenOffset, height: 0)
            currentRotation = -AppConstants.Swipe.maxRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Swipe.animationDuration) { [weak self] in
            self?.contentViewModel?.markForDeletion(photo)
            self?.cleanupPhoto(photo)
            self?.resetPosition()
        }
    }
    
    private func cleanupPhoto(_ photo: PhotoModel) {
        loadedImages.removeValue(forKey: photo.id)
    }
    
    private func resetPosition() {
        currentOffset = .zero
        currentRotation = 0
    }
    
    func jumpToPhoto(_ target: PhotoModel) {
        contentViewModel?.moveToFront(target)
    }
    
    func loadImageIfNeeded(for photo: PhotoModel) async {
        guard loadedImages[photo.id] == nil else { return }
        
        let targetSize = CGSize(
            width: UIScreen.main.bounds.width * 2,
            height: UIScreen.main.bounds.height * 1.3
        )
        
        if let image = await contentViewModel?.loadImage(for: photo, targetSize: targetSize) {
            loadedImages[photo.id] = image
        }
    }
    
    func loadThumbnailIfNeeded(for photo: PhotoModel) async {
        guard loadedThumbnails[photo.id] == nil else { return }
        if let thumbnail = await contentViewModel?.loadThumbnail(for: photo) {
            loadedThumbnails[photo.id] = thumbnail
        }
    }

    func loadThumbnailsForVisibleRange(photos: [PhotoModel]) async {
        let visibleRange = 0..<min(AppConstants.Thumbnail.preloadCount, photos.count)
        for index in visibleRange {
            let photo = photos[index]
            if loadedThumbnails[photo.id] == nil {
                if let thumbnail = await contentViewModel?.loadThumbnail(for: photo) {
                    loadedThumbnails[photo.id] = thumbnail
                }
            }
        }
    }
}
