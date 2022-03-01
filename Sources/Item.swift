import SpriteKit

public enum Item: Hashable {
    case
    cornelius,
    spike(Int),
    foe(Foe, Character),
    truffle(SKNode)
    
    func collides(at: CGPoint, with: Item, position: CGPoint) -> Bool {
        { this, other in
            abs(this.x - other.x) < horizontal + with.horizontal
            && abs(this.y - other.y) < vertical + with.vertical
        } (origin(from: at), with.origin(from: position))
    }
    
    private var horizontal: CGFloat {
        switch self {
        case .cornelius:
            return 14
        case .truffle:
            return 8
        case .spike:
            return 7
        case let .foe(foe, _):
            return foe.horizontal
        }
    }
    
    private var vertical: CGFloat {
        switch self {
        case .cornelius:
            return 14
        case .truffle:
            return 8
        case .spike:
            return 9
        case let .foe(foe, _):
            return foe.vertical
        }
    }
    
    private func origin(from: CGPoint) -> CGPoint {
        switch self {
        case .cornelius, .foe:
            return .init(x: from.x, y: from.y + Game.mid)
        default:
            return from
        }
    }
}
