import SpriteKit
import Combine

public final class Map {
    public let move = PassthroughSubject<CGPoint, Never>()
    public let face = PassthroughSubject<Face, Never>()
    public let over = PassthroughSubject<Over, Never>()
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
        let x = 2
        
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
            if area[position.x][position.y] {
                if walking == .none, face != .none {
                    self.face.send(.none)
                }
            } else {
                gravity(position: position)
            }
            
            self.jumping.send(.start)
        case .start:
            if area[position.x][position.y] {
                self.face.send(.jump)
                move(x: position.x, y: position.y + 1)
                self.jumping.send(jumping.next)
            } else {
                gravity(position: position)
            }
        default:
            if area[position.x][position.y + 1] {
                self.jumping.send(.start)
            } else {
                move(x: position.x, y: position.y + 1)
                self.jumping.send(jumping.next)
            }
        }
        
        if walking != .none {
            
            switch face {
            case .walk1:
                self.face.send(.walk2)
            case .walk2, .none:
                self.face.send(.walk1)
            default:
                break
            }
            
            if walking == .left {
                if direction == .right {
                    self.direction.send(.left)
                }
                
                if position.x > 1 {
                    move(x: position.x - 1, y: position.y)
                }
            } else {
                if direction == .left {
                    self.direction.send(.right)
                }
                
                if position.x < area.count - 2 {
                    move(x: position.x + 1, y: position.y)
                }
            }
        }
    }
    
    public subscript(_ character: Character) -> CGPoint {
        .init(x: .init(characters[character]!.x) * size,
              y: .init(characters[character]!.y) * size)
    }
    
    private func gravity(position: (x: Int, y: Int)) {
        move(x: position.x, y: position.y - 1)
        
        if characters[.cornelius]!.y < 2 {
            over.send(.fell)
        }
    }
    
    private func move(x: Int, y: Int) {
        characters[.cornelius] = (x: x, y: y)
        move.send(self[.cornelius])
    }
}
