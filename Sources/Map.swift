import SpriteKit
import Combine

private let movingHorizontal = 8.0
private let movingVertical = 4.0

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
        if jumping == 0 {
            let point = items[.cornelius]!
            let position = position(for: point)
            let below = (x: position.x, y: position.y - 1)
            
            if position.y > 0,
               ground(on: below),
               point.y.truncatingRemainder(dividingBy: tile) == 0 {
                if walking == .none, face != .none {
                    self.face.send(.none)
                }
            } else {
                let next = point.y - movingVertical
                
                if next < movingVertical {
                    state.send(.dead)
                }
                
                if next >= movingVertical {
                    move(y: next)
                }
            }
        }
    }
    
    public func jump(jumping: Int, face: Face) {
        let point = items[.cornelius]!
        let position = position(for: point)
        let below = (x: position.x, y: position.y - 1)
        let above = (x: position.x, y: position.y + 1)
        
        if face != .jump {
            self.face.send(.jump)
        }
        
        if position.y > 0,
           (jumping == 0
            && ground(on: below)
            && point.y.truncatingRemainder(dividingBy: tile) == 0)
            || jumping > 0 {
            
            if ground(on: above) {
                self.jumping.send(0)
            } else {
                let next = point.y + movingVertical
                
                if next < size.height - movingVertical {
                    move(y: next)
                }
                
                self.jumping.send(jumping < 12
                                  ? jumping + 1
                                  : 0)
            }
        }
    }
    
    public func walk(walking: Walking, face: Face, direction: Walking) {
        let point = items[.cornelius]!
        let position = position(for: point)
        let below = (x: position.x, y: position.y - 1)
        
        if walking == direction {
            if position.y > 0 && ground(on: below) {
                switch face {
                case .walk1:
                    self.face.send(.walk2)
                default:
                    self.face.send(.walk1)
                }
            }

            var delta = point.x + movingHorizontal
            
            if walking == .left {
                delta = point.x - movingHorizontal
            }
            
            let nextPoint = CGPoint(x: delta, y: point.y)
            let nextPosition = self.position(for: nextPoint)
            
            if nextPoint.x > movingHorizontal,
               nextPoint.x < size.width - movingHorizontal,
               !ground(on: nextPosition) {
                move(x: delta)
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
    
    private func ground(on: (x: Int, y: Int)) -> Bool {
        area[on.x][on.y]
    }
    
    private func position(for point: CGPoint) -> (x: Int, y: Int) {
        (x: .init(point.x / tile), y: .init(point.y / tile))
    }
}
