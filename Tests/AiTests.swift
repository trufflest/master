import XCTest
import SpriteKit
@testable import Master

final class AiTests: XCTestCase {
    private var group: SKTileGroup!
    private var ground: SKTileMapNode!
    private var game: Game!
    private var foe: Character!
    
    override func setUp() {
        group = .init(tileDefinition: .init())
        ground = .init(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                       columns: 200,
                       rows: 100,
                       tileSize: .init(width: 32, height: 32))
        foe = .init()
        game = .init()
    }

    func testDirection() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 6, y: 32 * 5)
        foe.direction = .right
        foe.face = .walk1(0)
        foe.position.x = 32 * 6
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .left)

        XCTAssertEqual(.none, foe.face)
        XCTAssertEqual(.left, foe.direction)
        XCTAssertEqual(32 * 6, foe.position.x)
    }
    
    func testWalking() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 6, y: 32 * 5)
        foe.direction = .left
        foe.face = .walk1(0)
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .left)
        
        XCTAssertEqual(.walk1(1), foe.face)
        XCTAssertEqual(188, foe.position.x)
    }
    
    func testNoWalking() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 6, y: 32 * 5)
        foe.direction = .left
        foe.face = .walk1(0)
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .none)
        
        XCTAssertEqual(.none, foe.face)
        XCTAssertEqual(32 * 6, game.items[.foe(.lizard, foe)]!.x)
    }
    
    func testWalkingFace() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 6, y: 32 * 5)
        foe.direction = .left
        foe.face = .walk1(2)

        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .left)
        
        XCTAssertEqual(.walk2(0), foe.face)
    }
    
    func testWalkingLeftEdge() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 0, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 8, y: 32 * 5)
        foe.direction = .left
        foe.face = .walk1(0)
        foe.position.x = 8
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .left)
        
        XCTAssertEqual(8, foe.position.x)
    }
    
    func testWalkingNoGround() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 0, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 100, y: 100)
        foe.direction = .right
        foe.face = .walk1(0)
        foe.position = .init(x: 100, y: 100)
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .right)
        
        XCTAssertEqual(.walk1(0), foe.face)
        XCTAssertEqual(106, foe.position.x)
    }
    
    func testWalkingRightEdge() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 199, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 199 + 24, y: 32 * 5)
        foe.direction = .right
        foe.face = .walk1(0)
        foe.position = .init(x: 32 * 199 + 24, y: 32 * 5)
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .right)
        
        XCTAssertEqual(32 * 199 + 24, foe.position.x)
    }
    
    func testWalkingCollision() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 6, y: 32 * 5)
        foe.direction = .left
        foe.face = .walk1(0)
        foe.position = .init(x: 32 * 6, y: 32 * 5)
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .left)
        
        XCTAssertEqual(32 * 6, foe.position.x)
        XCTAssertEqual(.none, foe.direction)
    }
    
    func testWalkingCloseToFloor() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 3)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 6, y: 32 * 5)
        foe.direction = .left
        foe.face = .walk1(0)
        foe.position = .init(x: 32 * 6, y: 32 * 5)
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .left)
        
        XCTAssertEqual(188, foe.position.x)
    }
    
    func testWalkingFoeCollision() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 4)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        game.load(ground: ground)
        game.items[.foe(.lizard, foe)] = .init(x: 32 * 5, y: 32 * 5)
        foe.direction = .right
        foe.face = .none
        foe.position = .init(x: 32 * 5, y: 32 * 5)

        let another = Character()
        another.position = .init(x: 32 * 5 + 24, y: 32 * 5)
        game.items[.foe(.lizard, another)] = another.position
        
        game.foe(foe: .foe(.lizard, foe), character: foe, walking: .right)
        
        XCTAssertEqual(32 * 5, foe.position.x)
        XCTAssertEqual(.walk1(0), foe.face)
        XCTAssertEqual(.none, foe.direction)
    }
}
