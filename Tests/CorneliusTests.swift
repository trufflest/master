import XCTest
import SpriteKit
import Combine
@testable import Master

final class CorneliusTests: XCTestCase {
    private var game: Game!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        game = .init()
        subs = .init()
    }
    
    func testAdd() {
        let sprite = SKNode()
        sprite.position = .init(x: 33, y: 44)
        game.add(cornelius: sprite)
        XCTAssertEqual(.init(x: 33, y: 44), game.items[.cornelius])
    }
    
    func testGoal() {
        let expect = expectation(description: "")
        
        let group = SKTileGroup(tileDefinition: .init())
        let ground = SKTileMapNode(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                                  columns: 200,
                                  rows: 100,
                                  tileSize: .init(width: 32, height: 32))
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 197, row: 4)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 198, row: 4)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 199, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 197, y: 32 * 5)
        
        game
            .state
            .sink {
                XCTAssertEqual(.finished, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.contact()
        
        waitForExpectations(timeout: 0.05)
    }
}
