import SpriteKit

public enum Item: Hashable {
    case
    cornelius,
    foe(Int),
    truffle(SKNode)
    
    var radius: CGFloat {
        switch self {
        case .cornelius:
            return 15
        case .truffle:
            return 10
        case .foe:
            return 0
        }
    }
    
    func collides(at: CGPoint, with: Item, position: CGPoint) -> Bool {
        abs(at.x - position.x) < radius + with.radius
        && abs(at.y - position.y) < radius + with.radius
    }
}
