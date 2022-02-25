import CoreGraphics

public enum Foe {
    case
    lizard
    
    var horizontal: CGFloat {
        switch self {
        case .lizard:
            return 14
        }
    }
    
    var vertical: CGFloat {
        switch self {
        case .lizard:
            return 14
        }
    }
}
