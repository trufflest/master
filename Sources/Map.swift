import SpriteKit
import Combine

public final class Map {
    public let moveX = PassthroughSubject<CGFloat, Never>()
    public let moveY = PassthroughSubject<CGFloat, Never>()
    public let face = PassthroughSubject<Face, Never>()
    public let state = PassthroughSubject<State, Never>()
    public let direction = PassthroughSubject<Direction, Never>()
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
        let x = 3
        
        while area[x].count > y + 1, area[x][y + 1] {
            y += 1
        }
        
        characters = [.cornelius : (x, y)]
    }
    
    public func update(jumping: Jumping,
                       walking: Walking,
                       face: Face,
                       direction: Direction) {
        
        var position = characters[.cornelius]!
        
        switch jumping {
        case .none, .start:
            if area[position.x][position.y],
               area[position.x - 1][position.y],
               area[position.x + 1][position.y] {
                
                if jumping == .none {
                    if walking == .none, face != .none {
                        self.face.send(.none)
                    }
                    self.jumping.send(.start)
                } else {
                    position = flying(y: position.y)
                    self.face.send(.jump)
                    self.jumping.send(jumping.next)
                }
            } else {
                position = gravity(y: position.y)
                
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
                position = flying(y: position.y)
                self.jumping.send(jumping.next)
            }
        }
        
        switch walking {
        case .left:
            if direction == .right {
                self.direction.send(.left)
                
                switch face {
                case .walk1, .walk2:
                    self.face.send(.none)
                default:
                    break
                }
            } else {
                if area[position.x][position.y] {
                    walk(face: face)
                }
                
                if position.x > 1,
                   !area[position.x - 1][position.y + 1] {
                    move(x: position.x - 1)
                }
            }
        case .right:
            if direction == .left {
                self.direction.send(.right)
                
                switch face {
                case .walk1, .walk2:
                    self.face.send(.none)
                default:
                    break
                }
            } else {
                if area[position.x][position.y] {
                    walk(face: face)
                }
                
                if position.x < area.count - 2,
                   !area[position.x + 1][position.y + 1] {
                    move(x: position.x + 1)
                }
            }
        default:
            break
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
