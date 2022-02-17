import SpriteKit
import Combine

private let moving = 8.0

public final class Map {
    public let moveX = PassthroughSubject<CGFloat, Never>()
    public let moveY = PassthroughSubject<CGFloat, Never>()
    public let face = PassthroughSubject<Face, Never>()
    public let state = PassthroughSubject<State, Never>()
    public let direction = PassthroughSubject<Walking, Never>()
    public let jumping = PassthroughSubject<Int, Never>()
    
    var items = [Item : CGPoint]()
    private(set) var area = [[Bool]]()
    private(set) var tile = CGFloat()
    private var mid = CGFloat()
    private var size = CGSize()
    
    public init() {
        
    }
    
    public func load(ground: SKTileMapNode) {
        tile = ground.tileSize.width
        mid = tile / 2
        size = ground.mapSize
        
        area = (0 ..< ground.numberOfColumns).map { x in
            (0 ..< ground.numberOfRows).map { y in
                ground.tileDefinition(atColumn: x, row: y) != nil
            }
        }
        
        var y = 0
        let x = 4
        
        while area[x].count > y + 1, area[x][y] {
            y += 1
        }
        
        items = [.cornelius : .init(x: (.init(x) * tile) + mid, y: .init(y) * tile)]
    }
    
    public func gravity(jumping: Int, face: Face) {
        let point = items[.cornelius]!
        let position = position(for: point)
        
        if jumping == 0 {
            if position.y > 0 && area[position.x][position.y - 1] {
                if face != .none {
                    self.face.send(.none)
                }
            } else {
                let next = point.y - moving
                
                if next < moving {
                    state.send(.dead)
                }
                
                if next >= moving {
                    move(y: next)
                }
            }
        }
    }
    
    public func jump(jumping: Int, face: Face) {
        let point = items[.cornelius]!
        let position = position(for: point)
        
        if face != .jump {
            self.face.send(.jump)
        }
        
        if jumping == 0
            && position.y > 0 && area[position.x][position.y - 1]
            || jumping > 0 {
            
            if area[position.x][position.y + 1] {
                self.jumping.send(0)
            } else {
                let next = point.y + moving
                
                if next < size.height - moving {
                    move(y: next)
                }
                
                self.jumping.send(jumping < 20
                                  ? jumping + 1
                                  : 0)
            }
        }
    }
    
    public func walk(walking: Walking, face: Face, direction: Walking) {
        let point = items[.cornelius]!
        let position = position(for: point)
        
        if walking == direction {
            if position.y > 0 && area[position.x][position.y - 1] {
                walk(face: face)
            }

            switch walking {
            case .left:
                if point.x > moving,
                   !area[position.x - 1][position.y] {
                    move(x: point.x - moving)
                }
            case .right:
                if point.x < size.width - moving,
                   !area[position.x + 1][position.y] {
                    move(x: point.x + moving)
                }
            default:
                break
            }
        } else {
            self.direction.send(walking)

            switch face {
            case .walk1, .walk2:
                self.face.send(.none)
            default:
                break
            }
        }
    }
    
    private func walk(face: Face) {
        switch face {
        case .walk1:
            self.face.send(.walk2)
        default:
            self.face.send(.walk1)
        }
    }
    
    private func move(x: CGFloat) {
        items[.cornelius]!.x = x
        moveX.send(items[.cornelius]!.x)
    }
    
    private func move(y: CGFloat) {
        items[.cornelius]!.y = y
        moveY.send(items[.cornelius]!.y)
    }
    
    private func position(for point: CGPoint) -> (x: Int, y: Int) {
        (x: .init(point.x / tile), y: .init(point.y / tile))
    }
}
