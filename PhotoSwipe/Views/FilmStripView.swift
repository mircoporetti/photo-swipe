import SwiftUI

struct FilmStripView: View {
    let photos: [PhotoModel]
    let currentPhotoId: String?
    let loadedThumbnails: [String: UIImage]
    let decisionFor: (String) -> SwipeAction?
    let onTapPhoto: (PhotoModel) -> Void
    var onPhotoAppear: ((PhotoModel) -> Void)? = nil
    
    private let thumbnailSize: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.8))
                    .frame(height: thumbnailSize + 16)
                
                VStack {
                    sprocketHoles
                    Spacer()
                    sprocketHoles
                }
                .frame(height: thumbnailSize + 16)
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 4) {
                            ForEach(photos) { photo in
                                thumbnailView(for: photo)
                                    .id(photo.id)
                                    .onAppear {
                                        onPhotoAppear?(photo)
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .onChange(of: currentPhotoId) { _, newId in
                        guard let newId else { return }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(newId, anchor: .center)
                        }
                    }
                    .onAppear {
                        if let currentPhotoId {
                            proxy.scrollTo(currentPhotoId, anchor: .center)
                        }
                    }
                }
            }
            
            if !photos.isEmpty, let currentPhotoId,
               let currentIndex = photos.firstIndex(where: { $0.id == currentPhotoId }) {
                Text("\(currentIndex + 1) / \(photos.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var sprocketHoles: some View {
        HStack(spacing: 12) {
            ForEach(0..<20, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 8, height: 3)
            }
        }
    }
    
    private func thumbnailView(for photo: PhotoModel) -> some View {
        let isCurrent = photo.id == currentPhotoId
        let decision = decisionFor(photo.id)
        
        return Button {
            onTapPhoto(photo)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                if let thumbnail = loadedThumbnails[photo.id] {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.5)
                        )
                }
                
                if let decision {
                    Circle()
                        .fill(decision == .keep ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 1)
                        )
                        .padding(3)
                }
            }
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isCurrent ? Color.white : Color.clear, lineWidth: 2)
            )
            .opacity(isCurrent ? 1.0 : 0.6)
            .scaleEffect(isCurrent ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
