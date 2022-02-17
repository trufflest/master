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
    public internal(set) var items = [Item : CGPoint]()
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
    
    public func gravity(jumping: Int, walking: Walking, face: Face) {
        if jumping < 1 {
            let point = items[.cornelius]!
            
            if ground(on: point) {
                if walking == .none, face != .none {
                    self.face.send(.none)
                }
                
                if jumping < 0 {
                    self.jumping.send(0)
                }
            } else {
                if point.y <= moving {
                    state.send(.dead)
                } else {
                    move(y: point.y - moving)
                    
                    if jumping == 0 {
                        self.jumping.send(-1)
                    }
                }
            }
        }
    }
    
    public func jump(jumping: Int, face: Face) {
        let point = items[.cornelius]!
        
        if face != .jump {
            self.face.send(.jump)
        }
        
        if (jumping == 0 && ground(on: point)) || jumping > 0 {
            let above = CGPoint(x: point.x, y: point.y + moving)
            if ground(on: above) {
                self.jumping.send(0)
            } else {
                if above.y < size.height - moving {
                    move(y: above.y)
                }
                
                self.jumping.send(jumping < 12
                                  ? jumping + 1
                                  : 0)
            }
        }
    }
    
    public func walk(walking: Walking, face: Face, direction: Walking) {
        let point = items[.cornelius]!
        
        if walking == direction {
            if ground(on: point) {
                switch face {
                case .walk1_1:
                    self.face.send(.walk1_2)
                case .walk1_2:
                    self.face.send(.walk2_1)
                default:
                    self.face.send(.walk1_1)
                }
            }

            var delta = point.x + moving
            
            if walking == .left {
                delta = point.x - moving
            }
            
            let nextPoint = CGPoint(x: delta, y: point.y)
            
            if nextPoint.x > moving,
               nextPoint.x < size.width - moving,
               !area(on: nextPoint) {
                move(x: delta)
            }
        } else {
            self.direction.send(walking)

            switch face {
            case .walk1_1, .walk1_2, .walk2_1, .walk2_2:
                self.face.send(.none)
            default:
                break
            }
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
    
    private func ground(on point: CGPoint) -> Bool {
        point.y > moving
        && point.y.truncatingRemainder(dividingBy: tile) == 0
        && area(on: .init(x: point.x, y: point.y - 1))
    }
    
    private func area(on point: CGPoint) -> Bool {
        area[.init(point.x / tile)][.init(point.y / tile)]
    }
}
