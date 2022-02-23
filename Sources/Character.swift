import SpriteKit

public class Character: SKSpriteNode {
    public var direction = Walking.none {
        didSet {
            switch direction {
            case .left:
                xScale = -1
            default:
                xScale = 1
            }
        }
    }
    
    public var face = Face.none {
        didSet {
            texture = textures[face.key]
        }
    }
    
    public var textures: [String : SKTexture] {
        [:]
    }
}
