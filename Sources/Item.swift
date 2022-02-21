import SpriteKit

public enum Item: Hashable {
    case
    cornelius,
    spike(UUID),
    foe(Int),
    truffle(SKNode)
    
    func collides(at: CGPoint, with: Item, position: CGPoint) -> Bool {
        abs(at.x - position.x) < horizontal + with.horizontal
        && abs(at.y - position.y) < vertical + with.vertical
    }
    
    private var horizontal: CGFloat {
        switch self {
        case .cornelius:
            return 15
        case .truffle:
            return 10
        case .spike:
            return 7
        case .foe:
            return 0
        }
    }
    
    private var vertical: CGFloat {
        switch self {
        case .cornelius:
            return 15
        case .truffle:
            return 10
        case .spike:
            return 9
        case .foe:
            return 0
        }
    }
}
