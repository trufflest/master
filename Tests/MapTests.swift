import XCTest
import SpriteKit
@testable import Master

final class MapTests: XCTestCase {
    func testSize() {
        let ground = SKTileMapNode(tileSet: .init(), columns: 6, rows: 5, tileSize: .zero)
        let map = Map(ground: ground)
        XCTAssertEqual(6, map.area.count)
        
        map
            .area
            .forEach {
                XCTAssertEqual(5, $0.count)
            }
    }
    
    func testEmpty() {
        let group = SKTileGroup(tileDefinition: .init())
        let ground = SKTileMapNode(tileSet: .init(tileGroups: [group], tileSetType: .grid), columns: 6, rows: 5, tileSize: .zero)
        ground.enableAutomapping = false
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 2, row: 3)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 3)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 3)
        
        XCTAssertNotNil(ground.tileDefinition(atColumn: 2, row: 3))
        
        let map = Map(ground: ground)
        
        for x in 0 ..< map.area.count {
            for y in 0 ..< map.area[x].count {
                switch y {
                case 3:
                    switch x {
                    case 2, 3, 4:
                        XCTAssertEqual(.ground, map.area[x][y])
                    default:
                        XCTAssertEqual(.empty, map.area[x][y])
                    }
                default:
                    XCTAssertEqual(.empty, map.area[x][y])
                }
            }
        }
    }
}
