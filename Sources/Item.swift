import SpriteKit

public enum Item: Hashable {
    case
    cornelius,
    foe(Int),
    truffle(SKNode)
    
    var radius: CGFloat {
        switch self {
        case .cornelius:
            return 16
        case .truffle:
            return 12
        case .foe:
            return 0
        }
    }
    
    func collides(at: CGPoint, with: Item, position: CGPoint) -> Bool {
        print("\(abs(at.x - position.x)) : \(abs(at.y - position.y))")
        return abs(at.x - position.x) < radius + with.radius
        && abs(at.y - position.y) < radius + with.radius
    }
}
