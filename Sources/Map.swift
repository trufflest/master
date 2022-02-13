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
        
        let position = characters[.cornelius]!
        
        switch jumping {
        case .none:
            if area[position.x][position.y],
               area[position.x - 1][position.y],
               area[position.x + 1][position.y] {
                
                if walking == .none, face != .none {
                    self.face.send(.none)
                }
            } else {
                gravity(y: position.y)
            }
            
            self.jumping.send(.start)
        case .start:
            if area[position.x][position.y],
               area[position.x - 1][position.y],
               area[position.x + 1][position.y] {
                
                flying(y: position.y)
                self.face.send(.jump)
                self.jumping.send(jumping.next)
            } else {
                gravity(y: position.y)
            }
        default:
            if area[position.x][position.y + 1] {
                self.jumping.send(.start)
            } else {
                flying(y: position.y)
                self.jumping.send(jumping.next)
            }
        }
        
        if walking != .none {
            if walking == .left {
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
                    
                    if position.x > 2,
                       !area[position.x - 1][position.y + 1] {
                        move(x: position.x - 1)
                    }
                }
            } else {
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
        case .walk2, .none:
            self.face.send(.walk1)
        default:
            break
        }
    }
    
    private func flying(y: Int) {
        let next = y + 1
        
        if next < area.first!.count - 1 {
            move(y: next)
        }
    }
    
    private func gravity(y: Int) {
        let next = y - 1
        
        if next < 1 {
            state.send(.fell)
        }
        
        if next >= 0 {
            move(y: next)
        }
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
