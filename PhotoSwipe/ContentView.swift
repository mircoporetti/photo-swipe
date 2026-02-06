import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    contentForAuthorizationStatus
                }
                .navigationTitle("PhotoSwipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
            }
            .opacity(showSplash ? 0 : 1)
            
            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .sheet(isPresented: $viewModel.showingDeleteConfirmation) {
            DeleteReviewView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            await viewModel.checkAuthorizationStatus()
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            withAnimation(.easeInOut(duration: 0.4)) {
                showSplash = false
            }
        }
    }
    
    @ViewBuilder
    private var contentForAuthorizationStatus: some View {
        switch viewModel.authorizationStatus {
        case .notDetermined:
            RequestAccessView { await viewModel.requestAuthorization() }
        case .authorized, .limited:
            MainContentView(viewModel: viewModel)
        case .denied, .restricted:
            DeniedAccessView()
        @unknown default:
            RequestAccessView { await viewModel.requestAuthorization() }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if viewModel.isAuthorized {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.undoLastDelete()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!viewModel.hasPhotosToDelete)
                .accessibilityIdentifier("undoButton")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.hasPhotosToDelete {
                    Button {
                        viewModel.showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("\(viewModel.photosToDeleteCount)")
                        }
                    }
                    .tint(.red)
                    .accessibilityIdentifier("trashCountButton")
                }
            }
        }
    }
}

private struct RequestAccessView: View {
    let onRequestAccess: () async -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Access Your Photos")
                .font(.title)
                .fontWeight(.bold)
            
            Text("PhotoSwipe needs access to your photo library to help you organize and clean up your photos.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Button("Grant Access") {
                Task { await onRequestAccess() }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("grantAccessButton")
        }
    }
}

private struct DeniedAccessView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Access Denied")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please enable photo access in Settings to use PhotoSwipe.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct MainContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading photos...")
            } else {
                CardStackView(viewModel: viewModel)
                .accessibilityIdentifier("cardStack")
                
                if !viewModel.photos.isEmpty {
                    ActionButtonsView(
                        onDelete: {
                            if let photo = viewModel.photos.first {
                                viewModel.markForDeletion(photo)
                            }
                        },
                        onKeep: {
                            if let photo = viewModel.photos.first {
                                viewModel.keepPhoto(photo)
                            }
                        }
                    )
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

private struct ActionButtonsView: View {
    let onDelete: () -> Void
    let onKeep: () -> Void
    
    var body: some View {
        HStack(spacing: 60) {
            ActionButton(icon: "xmark", color: .red, action: onDelete)
            ActionButton(icon: "heart.fill", color: .green, action: onKeep)
        }
    }
}

private struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .stroke(color, lineWidth: 3)
                )
        }
        .accessibilityIdentifier(icon == "xmark" ? "deleteButton" : "keepButton")
    }
}

private struct SplashView: View {
    @State private var appeared = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.tertiarySystemBackground))
                        .frame(width: 140, height: 190)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32, weight: .thin))
                                .foregroundColor(Color(.quaternaryLabel))
                        )
                        .scaleEffect(appeared ? 1 : 0.9)
                        .opacity(appeared ? 1 : 0)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 140, height: 190)
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
                        .overlay(
                            Image(systemName: "photo.fill")
                                .font(.system(size: 32, weight: .thin))
                                .foregroundColor(.accentColor)
                        )
                        .offset(x: cardOffset)
                        .rotationEffect(.degrees(cardRotation))
                        .scaleEffect(appeared ? 1 : 0.9)
                        .opacity(appeared ? 1 : 0)
                }
                
                VStack(spacing: 6) {
                    Text("PhotoSwipe")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    
                    Text("Swipe to organize")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    cardOffset = -30
                    cardRotation = -5
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        cardOffset = 30
                        cardRotation = 5
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            cardOffset = 0
                            cardRotation = 0
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
