import SpriteKit

open class Character: SKSpriteNode {
    open var direction = Walking.none {
        didSet {
            switch direction {
            case .left:
                xScale = -1
            case .right:
                xScale = 1
            default:
                break
            }
        }
    }
    
    open var face = Face.none {
        didSet {
            texture = textures[face.key]
        }
    }
    
    open var textures: [String : SKTexture] {
        [:]
    }
}
