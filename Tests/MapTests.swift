import XCTest
import SpriteKit
import Combine
@testable import Master

final class MapTests: XCTestCase {
    private var group: SKTileGroup!
    private var ground: SKTileMapNode!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        group = .init(tileDefinition: .init())
        ground = .init(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                       columns: 200,
                       rows: 100,
                       tileSize: .init(width: 32, height: 32))
        subs = .init()
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
                        XCTAssertTrue(map.area[x][y])
                    default:
                        XCTAssertFalse(map.area[x][y])
                    }
                default:
                    XCTAssertFalse(map.area[x][y])
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
        
        XCTAssertEqual(.init(x: 64, y: 64), Map(ground: ground)[.cornelius])
    }
    
    func testFalling() {
        let expect = expectation(description: "")
        let map = Map(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .move
            .sink {
                XCTAssertEqual(.init(x: 32 * 5, y: 32 * 4), $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none)
        
        waitForExpectations(timeout: 1)
    }
    
    func testOverFell() {
        let expectFace = expectation(description: "")
        let expectClear = expectation(description: "")
        
        let map = Map(ground: ground)
        map.characters[.cornelius] = (5, 2)
        
        map
            .over
            .sink {
                XCTAssertEqual(.fell, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumpClear
            .sink {
                expectClear.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none)
        
        waitForExpectations(timeout: 1)
    }
    
    func testGrounding() {
        let expectFace = expectation(description: "")
        let expectClear = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 2)
        
        let map = Map(ground: ground)
        map.characters[.cornelius] = (5, 2)
        
        map
            .face
            .sink {
                XCTAssertEqual(.none, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumpClear
            .sink {
                expectClear.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none)
        
        waitForExpectations(timeout: 1)
    }
    
    func testJump() {
        let expectFace = expectation(description: "")
        let expectMove = expectation(description: "")
        let expectConsume = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 2)
        
        let map = Map(ground: ground)
        map.characters[.cornelius] = (5, 2)
        
        map
            .face
            .sink {
                XCTAssertEqual(.jump, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .move
            .sink {
                XCTAssertEqual(.init(x: 32 * 5, y: 32 * 3), $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumpConsume
            .sink {
                expectConsume.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .start, walking: .none)
        
        waitForExpectations(timeout: 1)
    }
    
    func testOnTheUp() {
        let expectMove = expectation(description: "")
        let expectConsume = expectation(description: "")
        
        let map = Map(ground: ground)
        map.characters[.cornelius] = (5, 2)

        map
            .move
            .sink {
                XCTAssertEqual(.init(x: 32 * 5, y: 32 * 3), $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumpConsume
            .sink {
                expectConsume.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .second, walking: .none)
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpStop() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 3)
        
        let map = Map(ground: ground)
        map.characters[.cornelius] = (5, 2)
        
        map
            .jumpClear
            .sink {
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .second, walking: .none)
        
        waitForExpectations(timeout: 1)
    }
    
    
    
    func testWalking() {
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
//        var map = Map(ground: ground)
        
//        XCTAssertEqual(.init(x: 64, y: 96), map.start())
    }
}
