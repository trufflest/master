import XCTest
import SpriteKit
@testable import Master

final class AreaTests: XCTestCase {
    private var group: SKTileGroup!
    private var ground: SKTileMapNode!
    private var game: Game!
    
    override func setUp() {
        group = .init(tileDefinition: .init())
        ground = .init(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                       columns: 200,
                       rows: 100,
                       tileSize: .init(width: 32, height: 32))
        game = .init()
    }
    
    func testSize() {
        game.load(ground: ground)
        XCTAssertEqual(200, game.area.count)
        
        game
            .area
            .forEach {
                XCTAssertEqual(100, $0.count)
            }
    }
    
    func testEmpty() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 2, row: 3)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 3)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 3)
        
        game.load(ground: ground)
        
        for x in 0 ..< game.area.count {
            for y in 0 ..< game.area[x].count {
                switch y {
                case 3:
                    switch x {
                    case 2, 3, 4:
                        XCTAssertTrue(game.area[x][y])
                    default:
                        XCTAssertFalse(game.area[x][y])
                    }
                default:
                    XCTAssertFalse(game.area[x][y])
                }
            }
        }
    }
}
