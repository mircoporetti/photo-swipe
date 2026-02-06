import Foundation

enum SwipeAction {
    case keep
    case delete
    
    var color: String {
        switch self {
        case .keep: return "green"
        case .delete: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .keep: return "heart.fill"
        case .delete: return "trash.fill"
        }
    }
}
