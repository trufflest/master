import CoreGraphics

public enum Foe {
    case
    lizard
    
    var horizontal: CGFloat {
        switch self {
        case .lizard:
            return 12
        }
    }
    
    var vertical: CGFloat {
        switch self {
        case .lizard:
            return 12
        }
    }
}
