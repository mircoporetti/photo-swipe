import SwiftUI

struct PhotoCardView: View {
    let photo: PhotoModel
    let image: UIImage?
    
    @Binding var offset: CGSize
    @Binding var rotation: Double
    
    var body: some View {
        ZStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
            }
            
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "trash.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .opacity(offset.width < -30 ? min(Double(-offset.width - 30) / 80, 1) : 0)
                    .scaleEffect(offset.width < -30 ? min(Double(-offset.width - 30) / 80 + 0.5, 1.2) : 0.5)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .opacity(offset.width > 30 ? min(Double(offset.width - 30) / 80, 1) : 0)
                    .scaleEffect(offset.width > 30 ? min(Double(offset.width - 30) / 80 + 0.5, 1.2) : 0.5)
            }
            
            VStack {
                Spacer()
                if let date = photo.creationDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height * 0.55)
        .cornerRadius(20)
        .shadow(radius: 10)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .accessibilityIdentifier("photoCard_\(photo.id)")
    }
}
