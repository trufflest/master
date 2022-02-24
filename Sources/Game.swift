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
        let (truffles, foe, spike) = contact(point: cornelius, with: .cornelius)
        
        truffles
            .forEach {
                if case let .truffle(node) = $0 {
                    items.removeValue(forKey: $0)
                    truffle.send(node)
                }
            }

        if foe || spike {
            state.send(.dead)
            face.send(.dead)
        }
    }
    
    public func foes() {
        let items = items
        items
            .forEach { item in
                if case let .foe(_, character) = item.key {
                    let (_, _, spike) = contact(point: item.value, with: item.key)
                    
                    if spike {
                        self.items.removeValue(forKey: item.key)
                        character.run(.sequence([.fadeOut(withDuration: 1), .removeFromParent()]))
                    } else {
                        let walking = randomer(current: character.direction)
                        let (face, _, y, fell) = gravity(point: item.value, jumping: .ready, walking: walking, face: character.face)
                        
                        face
                            .map {
                                character.face = $0
                            }
                        
                        y
                            .map {
                                self.items[item.key]!.y = $0
                                character.position.y = $0
                            }
                        
                        if fell {
                            self.items.removeValue(forKey: item.key)
                            character.run(.sequence([.fadeOut(withDuration: 1), .removeFromParent()]))
                        } else if walking != .none {
                            foe(foe: item.key, character: character, walking: walking)
                        } else {
                            character.direction = walking
                        }
                    }
                }
            }
    }
    
    public func gravity(jumping: Jumping, walking: Walking, face: Face) {
        if jumping == .over || jumping == .ready {
            let (face, jumping, y, fell) = gravity(point: items[.cornelius]!, jumping: jumping, walking: walking, face: face)
            
            face
                .map {
                    self.face.send($0)
                }
            
            jumping
                .map {
                    self.jumping.send($0)
                }
            
            y
                .map {
                    items[.cornelius]!.y = $0
                    moveY.send($0)
                }
            
            if fell {
                state.send(.fell)
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
                        items[.cornelius]!.y = above.y
                        moveY.send(above.y)
                    }
                } else {
                    items[.cornelius]!.y = above.y
                    moveY.send(above.y)
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
                let (_, collide, _) = contact(point: .init(x: $0, y: items[foe]!.y + mid), with: foe)
                
                if !collide {
                    items[foe]!.x = $0
                    character.position.x = $0
                }
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
    
    private func contact(point: CGPoint, with: Item) -> (truffles: [Item], foe: Bool, spike: Bool) {
        var result: (truffles: [Item], foe: Bool, spike: Bool) = ([], false, false)
        
        items
            .forEach {
                guard $0.key != with else { return }
                if $0.key.collides(at: $0.value, with: with, position: point) {
                    switch $0.key {
                    case .truffle:
                        result.truffles.append($0.key)
                    case .spike:
                        result.spike = true
                    case .foe:
                        result.foe = true
                    default:
                        break
                    }
                }
            }
        
        return result
    }
    
    private func gravity(point: CGPoint,
                         jumping: Jumping,
                         walking: Walking,
                         face: Face) -> (face: Face?, jumping: Jumping?, y: CGFloat?, fell: Bool) {

        var result: (face: Face?, jumping: Jumping?, y: CGFloat?, fell: Bool) = (nil, nil, nil, false)
        
        if ground(on: point) {
            if walking == .none, face != .none {
                result.face = Face.none
            }
            
            if jumping == .over {
                result.jumping = .ready
            }
        } else {
            if point.y <= moving {
                result.fell = true
            } else {
                result.y = point.y - (moving * 2)
                
                if jumping == .ready {
                    result.jumping = .over
                }
            }
        }
        
        return result
    }
    
    private func randomer(current: Walking) -> Walking {
        switch Int.random(in: 0 ..< 300) {
        case 0 ..< 298:
            return current
        case 298:
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
