import SwiftUI

struct SwipeEffectView: View {
    let action: SwipeAction?
    let isAnimating: Bool
    
    var body: some View {
        ZStack {
            if isAnimating {
                switch action {
                case .keep:
                    KeepEffectView()
                case .delete:
                    DeleteEffectView()
                case .none:
                    EmptyView()
                }
            }
        }
    }
}

struct KeepEffectView: View {
    @State private var hearts: [HeartParticle] = []
    @State private var showGlow = false
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.green.opacity(0.6), .green.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .scaleEffect(showGlow ? 2.5 : 0.5)
                .opacity(showGlow ? 0 : 1)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.white, .green)
                .scaleEffect(showCheckmark ? 1.2 : 0.3)
                .opacity(showCheckmark ? 0 : 1)
            
            ForEach(hearts) { heart in
                Image(systemName: "heart.fill")
                    .font(.system(size: heart.size))
                    .foregroundColor(.green.opacity(0.8))
                    .offset(heart.offset)
                    .opacity(heart.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showGlow = true
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                showCheckmark = true
            }
            createHearts()
        }
    }
    
    private func createHearts() {
        for i in 0..<12 {
            let angle = Double(i) * (360.0 / 12.0) * .pi / 180
            let heart = HeartParticle(
                id: i,
                size: CGFloat.random(in: 15...30),
                offset: .zero,
                opacity: 1
            )
            hearts.append(heart)
            
            withAnimation(.easeOut(duration: 0.6).delay(Double(i) * 0.02)) {
                hearts[i].offset = CGSize(
                    width: cos(angle) * CGFloat.random(in: 100...180),
                    height: sin(angle) * CGFloat.random(in: 100...180)
                )
                hearts[i].opacity = 0
            }
        }
    }
}

struct DeleteEffectView: View {
    @State private var showX = false
    @State private var particles: [DeleteParticle] = []
    @State private var showShatter = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.red.opacity(0.5), .red.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .scaleEffect(showShatter ? 2 : 0.5)
                .opacity(showShatter ? 0 : 1)
            
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.white, .red)
                .scaleEffect(showX ? 1.2 : 0.3)
                .opacity(showX ? 0 : 1)
                .rotationEffect(.degrees(showX ? 180 : 0))
            
            ForEach(particles) { particle in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red.opacity(0.7))
                    .frame(width: particle.size, height: particle.size)
                    .offset(particle.offset)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showShatter = true
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showX = true
            }
            createParticles()
        }
    }
    
    private func createParticles() {
        for i in 0..<16 {
            let angle = Double.random(in: 0...(2 * .pi))
            let particle = DeleteParticle(
                id: i,
                size: CGFloat.random(in: 8...20),
                offset: .zero,
                rotation: 0,
                opacity: 1
            )
            particles.append(particle)
            
            withAnimation(.easeOut(duration: 0.5).delay(Double(i) * 0.015)) {
                particles[i].offset = CGSize(
                    width: cos(angle) * CGFloat.random(in: 80...160),
                    height: sin(angle) * CGFloat.random(in: 80...160)
                )
                particles[i].rotation = Double.random(in: -180...180)
                particles[i].opacity = 0
            }
        }
    }
}

struct HeartParticle: Identifiable {
    let id: Int
    var size: CGFloat
    var offset: CGSize
    var opacity: Double
}

struct DeleteParticle: Identifiable {
    let id: Int
    var size: CGFloat
    var offset: CGSize
    var rotation: Double
    var opacity: Double
}

#Preview {
    VStack(spacing: 100) {
        KeepEffectView()
        DeleteEffectView()
    }
}
