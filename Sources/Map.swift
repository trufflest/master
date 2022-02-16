import SpriteKit
import Combine

public final class Map {
    public let moveX = PassthroughSubject<CGFloat, Never>()
    public let moveY = PassthroughSubject<CGFloat, Never>()
    public let face = PassthroughSubject<Face, Never>()
    public let state = PassthroughSubject<State, Never>()
    public let direction = PassthroughSubject<Walking, Never>()
    public let jumping = PassthroughSubject<Jumping, Never>()
    
    var characters = [Character : (x: Int, y: Int)]()
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
        
        characters = [.cornelius : (x, y)]
    }
    
    public func update(jumping: Jumping,
                       walking: Walking,
                       face: Face,
                       direction: Walking) {
        
        let position = characters[.cornelius]!
        var updated = position
        
        switch jumping {
        case .none, .start:
            if position.y > 0 && area[position.x][position.y - 1] {
                if jumping == .none {
                    if walking == .none, face != .none {
                        self.face.send(.none)
                    }
                    self.jumping.send(.start)
                } else {
                    updated = flying(y: position.y)
                    self.face.send(.jump)
                    self.jumping.send(jumping.next)
                }
            } else {
                updated = gravity(y: position.y)
                
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
                updated = flying(y: position.y)
                self.jumping.send(jumping.next)
            }
        }
        
        if walking != .none {
            if walking == direction {
                if updated.y > 0 && area[updated.x][updated.y - 1] {
                    walk(face: face)
                }
                
                switch walking {
                case .left:
                    if updated.x > 1,
                       !area[updated.x - 1][updated.y],
                       !area[updated.x - 1][position.y] {
                        move(x: updated.x - 1)
                    }
                case .right:
                    if updated.x < area.count - 2,
                       !area[updated.x + 1][updated.y],
                       !area[updated.x + 1][position.y] {
                        move(x: updated.x + 1)
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
    
    public subscript(_ character: Character) -> CGPoint {
        .init(x: .init(characters[character]!.x) * size,
              y: .init(characters[character]!.y) * size)
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
        
        return characters[.cornelius]!
    }
    
    private func gravity(y: Int) -> (x: Int, y: Int) {
        let next = y - 1
        
        if next < 1 {
            state.send(.dead)
        }
        
        if next >= 0 {
            move(y: next)
        }
        
        return characters[.cornelius]!
    }
    
    private func move(x: Int) {
        characters[.cornelius] = (x: x, y: characters[.cornelius]!.y)
        moveX.send(self[.cornelius].x)
    }
    
    private func move(y: Int) {
        characters[.cornelius] = (x: characters[.cornelius]!.x, y: y)
        moveY.send(self[.cornelius].y)
    }
}
