import XCTest
import SpriteKit
import Combine
@testable import Master

final class NpcTests: XCTestCase {
    private var group: SKTileGroup!
    private var ground: SKTileMapNode!
    private var game: Game!
    private var npc: Character!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        group = .init(tileDefinition: .init())
        ground = .init(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                       columns: 200,
                       rows: 100,
                       tileSize: .init(width: 32, height: 32))
        game = .init()
        npc = .init()
        subs = .init()
    }
    
    func testSpike() {
        game.load(ground: ground)
        game.items[.foe(.lizard, npc)] = .init(x: 50 + (12 - 1) + 6,
                                               y: 50 - 16 - (12 - 1) - 8)
        game.items[.spike(0)] = .init(x: 50, y: 50)

        XCTAssertNotNil(game.items[.foe(.lizard, npc)])
        game.foes()
        XCTAssertNil(game.items[.foe(.lizard, npc)])
    }
    
    func testGravity() {
        game.load(ground: ground)
        game.items[.foe(.lizard, npc)] = .init(x: 100, y: 100)
        game.foes()
        XCTAssertEqual(92, game.items[.foe(.lizard, npc)]!.y)
        XCTAssertEqual(92, npc.position.y)
    }
    
    func testFallingEdge() {
        game.load(ground: ground)
        game.items[.foe(.lizard, npc)] = .init(x: 100, y: 4)
        
        XCTAssertNotNil(game.items[.foe(.lizard, npc)])
        game.foes()
        XCTAssertNil(game.items[.foe(.lizard, npc)])
    }
}
