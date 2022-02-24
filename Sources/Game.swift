import SpriteKit
import Combine

private let moving = 4.0

public final class Game {
    public let moveX = PassthroughSubject<CGFloat, Never>()
    public let moveY = PassthroughSubject<CGFloat, Never>()
    public let face = PassthroughSubject<Face, Never>()
    public let state = PassthroughSubject<State, Never>()
    public let direction = PassthroughSubject<Walking, Never>()
    public let jumping = PassthroughSubject<Jumping, Never>()
    public let truffle = PassthroughSubject<SKNode, Never>()
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
    }
    
    public func load(truffles: SKNode) {
        truffles
            .children
            .forEach {
                items[.truffle($0)] = $0.position
            }
    }
    
    public func load(spikes: SKNode) {
        spikes
            .children
            .enumerated()
            .forEach {
                items[.spike($0.0)] = $0.1.position
            }
    }
    
    public func load(lizards: SKNode) {
        lizards
            .children
            .forEach {
                items[.foe(.lizard, $0 as! Character)] = $0.position
            }
    }
    
    public func add(cornelius: SKNode) {
        items[.cornelius] = cornelius.position
    }
    
    public func contact() {
        var cornelius = items[.cornelius]!
        cornelius.y += mid
        contact(point: cornelius, with: .cornelius)
    }
    
    public func foes() {
        items
            .forEach {
                if case let .foe(_, character) = $0.key {
                    foe(foe: $0.key, character: character, walking: randomer(current: character.direction))
                }
            }
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
                    state.send(.fell)
                } else {
                    move(y: point.y - (moving * 2))
                    
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
            
            let above = CGPoint(x: point.x, y: point.y + (moving * 2))
            if ceiling(on: above) || above.y > size.height - mid {
                if jumping != .ready {
                    self.jumping.send(.over)
                }
            } else {
                if case let .counter(counter) = jumping {
                    if counter <= 10 {
                        move(y: above.y)
                    }
                } else {
                    move(y: above.y)
                }
                
                switch jumping {
                case let .counter(counter):
                    if counter < 14 {
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
        let (face, direction, x) = walk(point: items[.cornelius]!, walking: walking, face: face, direction: direction)
        
        face
            .map {
                self.face.send($0)
            }
        
        direction
            .map {
                self.direction.send($0)
            }
        
        x
            .map {
                items[.cornelius]!.x = $0
                moveX.send($0)
            }
    }
    
    func foe(foe: Item, character: Character, walking: Walking) {
        let (face, direction, x) = walk(point: items[foe]!,
                                        walking: walking,
                                        face: character.face,
                                        direction: character.direction)
        
        face
            .map {
                character.face = $0
            }
        
        direction
            .map {
                character.direction = $0
            }
        
        x
            .map {
                
                
                items[foe]!.x = $0
                character.position.x = $0
            }
    }
    
    private func walk(point: CGPoint, walking: Walking, face: Face, direction: Walking) -> (face: Face?, direction: Walking?, x: CGFloat?) {
        var result: (face: Face?, direction: Walking?, x: CGFloat?) = (nil, nil, nil)
        
        if walking == direction {
            let grounded = ground(on: point)
            
            if grounded {
                switch face {
                case let .walk1(counter):
                    if counter > 1 {
                        result.face = .walk2(0)
                    } else {
                        result.face = .walk1(counter + 1)
                    }
                case let .walk2(counter):
                    if counter > 1 {
                        result.face = .walk1(0)
                    } else {
                        result.face = .walk2(counter + 1)
                    }
                default:
                    result.face = .walk1(0)
                }
            }

            var distance = moving
            
            if !grounded,
               point.y > tile + moving,
               !ground(on: .init(x: point.x, y: point.y - tile)) {
                distance *= 1.5
            }
            
            var delta = point.x + distance
            
            if walking == .left {
                delta = point.x - distance
            }
            
            let nextPoint = CGPoint(x: delta, y: point.y)
            
            if nextPoint.x > moving,
               nextPoint.x < size.width - moving,
               !area(on: nextPoint),
               !area(on: .init(x: nextPoint.x, y: nextPoint.y + mid)) {
                result.x = delta
            }
        } else {
            result.direction = walking

            switch face {
            case .walk1, .walk2:
                result.face = Face.none
            default:
                break
            }
        }
        return result
    }
    
    private func contact(point: CGPoint, with: Item) {
    outer: for item in items {
        guard item.key != with else { continue }
            if item.key.collides(at: item.value, with: with, position: point) {
                switch item.key {
                case let .truffle(truffle):
                    self.items.removeValue(forKey: item.key)
                    self.truffle.send(truffle)
                case .spike:
                    self.state.send(.dead)
                    self.face.send(.dead)
                    break outer
                case .foe:
                    self.state.send(.dead)
                    self.face.send(.dead)
                    break outer
                default:
                    break
                }
            }
        }
    }
    
    private func randomer(current: Walking) -> Walking {
        switch Int.random(in: 0 ..< 10) {
        case 0 ..< 6:
            return current
        case 6 ..< 8:
            switch current {
            case .none:
                return .left
            case .left:
                return .right
            case .right:
                return .none
            }
        default:
            switch current {
            case .none:
                return .right
            case .left:
                return .none
            case .right:
                return .left
            }
        }
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
