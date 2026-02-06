import Foundation
import CoreGraphics

enum AppConstants {
    enum Swipe {
        static let threshold: CGFloat = 100
        static let animationDuration: Double = 0.3
        static let offscreenOffset: CGFloat = 500
        static let maxRotation: Double = 15
    }
    
    enum Thumbnail {
        static let size = CGSize(width: 100, height: 100)
        static let displaySize: CGFloat = 50
        static let preloadCount = 20
    }
    
    enum Card {
        static let stackCount = 3
        static let scaleDecrement: CGFloat = 0.05
        static let verticalOffset: CGFloat = 10
    }
}
