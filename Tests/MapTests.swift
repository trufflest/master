import XCTest
import SpriteKit
@testable import Master

final class MapTests: XCTestCase {
    private var group: SKTileGroup!
    private var ground: SKTileMapNode!
    
    override func setUp() {
        group = .init(tileDefinition: .init())
        ground = .init(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                       columns: 200,
                       rows: 100,
                       tileSize: .init(width: 32, height: 32))
    }
    
    func testSize() {
        let map = Map(ground: ground)
        XCTAssertEqual(200, map.area.count)
        
        map
            .area
            .forEach {
                XCTAssertEqual(100, $0.count)
            }
    }
    
    func testEmpty() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 2, row: 3)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 3)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 3)
        
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
    
    func testOrigin() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 0, row: 0)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 0, row: 1)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 0, row: 2)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 1, row: 0)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 1, row: 1)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 1, row: 2)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 2, row: 0)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 2, row: 1)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 2, row: 2)
        
        XCTAssertEqual(.init(x: 64, y: 96), Map(ground: ground)[.cornelius])
    }
    
    func testFalling() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        var map = Map(ground: ground)
        
        XCTAssertEqual(.init(x: 64, y: 96), map.start())
    }
}
