import SpriteKit
import Combine

public final class Map {
    public let moveX = PassthroughSubject<CGFloat, Never>()
    public let moveY = PassthroughSubject<CGFloat, Never>()
    public let face = PassthroughSubject<Face, Never>()
    public let state = PassthroughSubject<State, Never>()
    public let direction = PassthroughSubject<Walking, Never>()
    public let jumping = PassthroughSubject<Jumping, Never>()
    
    var items = [Item : (x: Int, y: Int)]()
    private(set) var area = [[Bool]]()
    private(set) var size = CGFloat()
    
    public init() {
        
    }
    
    public func load(ground: SKTileMapNode) {
        size = ground.tileSize.width
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
        
        items = [.cornelius : (x, y)]
    }
    
    public func jump(jumping: Jumping, face: Face) {
        let position = items[.cornelius]!
        
        switch jumping {
        case .none, .start:
            if position.y > 0 && area[position.x][position.y - 1] {
                if jumping == .none {
                    if face != .none {
                        self.face.send(.none)
                    }
                    self.jumping.send(.start)
                } else {
                    flying(y: position.y)
                    self.face.send(.jump)
                    self.jumping.send(jumping.next)
                }
            } else {
                gravity(y: position.y)
                
                if jumping == .none {
                    self.jumping.send(.start)
                }
            }
        default:
            if face != .jump {
                self.face.send(.jump)
            }
            
            if area[position.x][position.y + 1] {
                self.jumping.send(.start)
            } else {
                flying(y: position.y)
                self.jumping.send(jumping.next)
            }
        }
    }
    
    public func walk(walking: Walking, face: Face, direction: Walking) {
        let position = items[.cornelius]!
        
        if walking != .none {
            if walking == direction {
                if position.y > 0 && area[position.x][position.y - 1] {
                    walk(face: face)
                }

                switch walking {
                case .left:
                    if position.x > 1,
                       !area[position.x - 1][position.y],
                       !area[position.x - 1][position.y] {
                        move(x: position.x - 1)
                    }
                case .right:
                    if position.x < area.count - 2,
                       !area[position.x + 1][position.y],
                       !area[position.x + 1][position.y] {
                        move(x: position.x + 1)
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
    }
    
    public subscript(_ character: Item) -> CGPoint {
        .init(x: .init(items[character]!.x) * size,
              y: .init(items[character]!.y) * size)
    }
    
    private func walk(face: Face) {
        switch face {
        case .walk1:
            self.face.send(.walk2)
        default:
            self.face.send(.walk1)
        }
    }
    
    private func flying(y: Int) -> (x: Int, y: Int) {
        let next = y + 1
        
        if next < area.first!.count - 1 {
            move(y: next)
        }
        
        return items[.cornelius]!
    }
    
    private func gravity(y: Int) -> (x: Int, y: Int) {
        let next = y - 1
        
        if next < 1 {
            state.send(.dead)
        }
        
        if next >= 0 {
            move(y: next)
        }
        
        return items[.cornelius]!
    }
    
    private func move(x: Int) {
        items[.cornelius] = (x: x, y: items[.cornelius]!.y)
        moveX.send(self[.cornelius].x)
    }
    
    private func move(y: Int) {
        items[.cornelius] = (x: items[.cornelius]!.x, y: y)
        moveY.send(self[.cornelius].y)
    }
}
