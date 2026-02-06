import SwiftUI

struct DeleteReviewView: View {
    @ObservedObject var viewModel: ContentViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var loadedThumbnails: [String: UIImage] = [:]
    
    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.photosMarkedForDeletion.isEmpty {
                    emptyState
                } else {
                    photoGrid
                }
                
                if viewModel.photosToDeleteCount > 0 {
                    deleteButton
                }
            }
            .navigationTitle("Review Deletions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("reviewDoneButton")
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("No photos to delete")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var photoGrid: some View {
        ScrollView {
            Text("\(viewModel.photosToDeleteCount) photo\(viewModel.photosToDeleteCount == 1 ? "" : "s") marked for deletion")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 12)
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.photosMarkedForDeletion) { photo in
                    deletionThumbnail(for: photo)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 80)
        }
    }
    
    private func deletionThumbnail(for photo: PhotoModel) -> some View {
        ZStack(alignment: .topTrailing) {
            if let thumbnail = loadedThumbnails[photo.id] {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(ProgressView().scaleEffect(0.7))
                    .task {
                        if let thumb = await viewModel.loadThumbnail(for: photo) {
                            loadedThumbnails[photo.id] = thumb
                        }
                    }
            }
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    viewModel.restorePhoto(photo)
                }
            } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 24))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
                    .shadow(radius: 2)
            }
            .accessibilityIdentifier("restoreButton")
            .padding(6)
        }
        .cornerRadius(8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("deletionThumbnail")
    }
    
    private var deleteButton: some View {
        Button {
            Task {
                await viewModel.executeDeletes()
                dismiss()
            }
        } label: {
            Label("Delete \(viewModel.photosToDeleteCount) Photo\(viewModel.photosToDeleteCount == 1 ? "" : "s")", systemImage: "trash")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(14)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .accessibilityIdentifier("confirmDeleteButton")
    }
}
