import SwiftUI

struct CardStackView: View {
    @ObservedObject var viewModel: ContentViewModel
    @StateObject private var cardViewModel = CardStackViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.photos.isEmpty {
                EmptyStateView(
                    keptCount: viewModel.keptPhotosCount,
                    deleteCount: viewModel.photosToDeleteCount,
                    totalReviewed: viewModel.totalReviewed,
                    onDelete: { Task { await viewModel.executeDeletes() } }
                )
            } else {
                VStack(spacing: 16) {
                    cardStack
                    
                    FilmStripView(
                        photos: viewModel.allPhotos,
                        currentPhotoId: viewModel.photos.first?.id,
                        loadedThumbnails: cardViewModel.loadedThumbnails,
                        decisionFor: { viewModel.decisionFor($0) },
                        onTapPhoto: { photo in
                            cardViewModel.jumpToPhoto(photo)
                        },
                        onPhotoAppear: { photo in
                            Task {
                                await cardViewModel.loadThumbnailIfNeeded(for: photo)
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            cardViewModel.setContentViewModel(viewModel)
        }
        .onChange(of: viewModel.photos) { _, newPhotos in
            Task {
                for photo in newPhotos.prefix(AppConstants.Card.stackCount) {
                    await cardViewModel.loadImageIfNeeded(for: photo)
                }
            }
        }
        .task {
        }
    }
    
    private var cardStack: some View {
        ZStack {
            ForEach(Array(viewModel.photos.prefix(AppConstants.Card.stackCount).enumerated().reversed()), id: \.element.id) { index, photo in
                let isTopCard = index == 0
                
                PhotoCardView(
                    photo: photo,
                    image: cardViewModel.loadedImages[photo.id],
                    offset: isTopCard ? $cardViewModel.currentOffset : .constant(.zero),
                    rotation: isTopCard ? $cardViewModel.currentRotation : .constant(0)
                )
                .scaleEffect(isTopCard ? 1 : 1 - CGFloat(index) * AppConstants.Card.scaleDecrement)
                .offset(y: CGFloat(index) * AppConstants.Card.verticalOffset)
                .allowsHitTesting(isTopCard)
                .gesture(isTopCard ? swipeGesture(for: photo) : nil)
                .task {
                    await cardViewModel.loadImageIfNeeded(for: photo)
                }
            }
        }
    }
    
    private func swipeGesture(for photo: PhotoModel) -> some Gesture {
        DragGesture()
            .onChanged { value in
                cardViewModel.handleSwipeChange(value.translation)
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cardViewModel.handleSwipeEnd(value.translation, photo: photo)
                }
            }
    }
}

private struct EmptyStateView: View {
    let keptCount: Int
    let deleteCount: Int
    let totalReviewed: Int
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.stack")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("All done!")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityIdentifier("allDoneText")
            
            Text("You've reviewed all your photos")
                .foregroundColor(.secondary)
            
            if totalReviewed > 0 {
                VStack(spacing: 8) {
                    Text("\(keptCount) kept • \(deleteCount) to delete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if deleteCount > 0 {
                        Button("Delete \(deleteCount) Photos") {
                            onDelete()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .accessibilityIdentifier("confirmDeleteButton")
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}
