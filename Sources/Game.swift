import SpriteKit
import Combine

private let moving = 8.0

public final class Game {
    public let moveX = PassthroughSubject<CGFloat, Never>()
    public let moveY = PassthroughSubject<CGFloat, Never>()
    public let face = PassthroughSubject<Face, Never>()
    public let state = PassthroughSubject<State, Never>()
    public let direction = PassthroughSubject<Walking, Never>()
    public let jumping = PassthroughSubject<Jumping, Never>()
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
    
    public func gravity(jumping: Jumping, walking: Walking, face: Face) {
        if jumping == .over || jumping == .ready {
            let point = items[.cornelius]!
            
            if ground(on: point) {
                if walking == .none, face != .none {
                    self.face.send(.none)
                }
                
                if jumping == .over {
                    self.jumping.send(.ready)
                }
            } else {
                if point.y <= moving {
                    state.send(.dead)
                } else {
                    move(y: point.y - moving)
                    
                    if jumping == .ready {
                        self.jumping.send(.over)
                    }
                }
            }
        }
    }
    
    public func jump(jumping: Jumping, face: Face) {
        let point = items[.cornelius]!
        
        if face != .jump {
            self.face.send(.jump)
        }
        
        if (jumping == .ready && ground(on: point))
            || (jumping != .ready && jumping != .over) {
            
            let above = CGPoint(x: point.x, y: point.y + moving)
            if ceiling(on: above) {
                if jumping != .ready {
                    self.jumping.send(.over)
                }
            } else {
                if above.y < size.height - moving {
                    move(y: above.y)
                }
                
                switch jumping {
                case let .counter(counter):
                    if counter < 11 {
                        self.jumping.send(.counter(counter + 1))
                    } else {
                        self.jumping.send(.over)
                    }
                case .ready:
                    self.jumping.send(.counter(0))
                default:
                    break
                }
            }
        }
    }
    
    public func walk(walking: Walking, face: Face, direction: Walking) {
        let point = items[.cornelius]!
        
        if walking == direction {
            let grounded = ground(on: point)
            if grounded {
                switch face {
                case let .walk1(counter):
                    if counter > 1 {
                        self.face.send(.walk2(0))
                    } else {
                        self.face.send(.walk1(counter + 1))
                    }
                case let .walk2(counter):
                    if counter > 1 {
                        self.face.send(.walk1(0))
                    } else {
                        self.face.send(.walk2(counter + 1))
                    }
                default:
                    self.face.send(.walk1(0))
                }
            }

            var delta = point.x + (grounded ? moving : moving / 2)
            
            if walking == .left {
                delta = point.x - (grounded ? moving : moving / 2)
            }
            
            let nextPoint = CGPoint(x: delta, y: point.y)
            
            if nextPoint.x > moving,
               nextPoint.x < size.width - moving,
               !area(on: nextPoint),
               !area(on: .init(x: nextPoint.x, y: nextPoint.y + mid)) {
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
    
    private func ceiling(on point: CGPoint) -> Bool {
        point.y >= size.height - (moving + mid)
        || (point.y < size.height - (moving + mid)
            && area(on: .init(x: point.x, y: point.y + (moving + mid))))
    }
    
    private func area(on point: CGPoint) -> Bool {
        area[.init(point.x / tile)][.init(point.y / tile)]
    }
}
