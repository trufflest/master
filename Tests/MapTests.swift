import XCTest
import SpriteKit
import Combine
@testable import Master

final class MapTests: XCTestCase {
    private var group: SKTileGroup!
    private var ground: SKTileMapNode!
    private var map: Map!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        group = .init(tileDefinition: .init())
        ground = .init(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                       columns: 200,
                       rows: 100,
                       tileSize: .init(width: 32, height: 32))
        map = .init()
        subs = .init()
    }
    
    func testSize() {
        map.load(ground: ground)
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
        
        map.load(ground: ground)
        
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
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 0)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 1)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 2)
        
        map.load(ground: ground)
        XCTAssertEqual(.init(x: 96, y: 64), map[.cornelius])
    }
    
    func testFalling() {
        let expect = expectation(description: "")
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .moveY
            .sink {
                XCTAssertEqual(32 * 4, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testFallingCornerLeft() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .moveY
            .sink {
                XCTAssertEqual(32 * 4, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testFallingCornerRight() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (3, 5)
        
        map
            .moveY
            .sink {
                XCTAssertEqual(32 * 4, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testFallingCornerLeftStart() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .moveY
            .sink {
                XCTAssertEqual(32 * 4, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .start, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testFallingCornerRightStart() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (3, 5)
        
        map
            .moveY
            .sink {
                XCTAssertEqual(32 * 4, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .start, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testFallingEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 0)
        
        map
            .moveY
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOverFell() {
        let expectOver = expectation(description: "")
        let expectJumping = expectation(description: "")
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 0)
        
        map
            .state
            .sink {
                XCTAssertEqual(.fell, $0)
                expectOver.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumping
            .sink {
                XCTAssertEqual(.start, $0)
                expectJumping.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testGrounding() {
        let expectFace = expectation(description: "")
        let expectJumping = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 2)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 2)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 2)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 2)
        
        map
            .face
            .sink {
                XCTAssertEqual(.none, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumping
            .sink {
                XCTAssertEqual(.start, $0)
                expectJumping.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .none, face: .walk1, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testJump() {
        let expectFace = expectation(description: "")
        let expectMove = expectation(description: "")
        let expectJumping = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 2)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 2)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 2)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 2)
        
        map
            .face
            .sink {
                XCTAssertEqual(.jump, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .moveY
            .sink {
                XCTAssertEqual(32 * 3, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumping
            .sink {
                XCTAssertEqual(.first, $0)
                expectJumping.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .start, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOnTheUp() {
        let expectMove = expectation(description: "")
        let expectJumping = expectation(description: "")
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 2)

        map
            .moveY
            .sink {
                XCTAssertEqual(32 * 3, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map
            .jumping
            .sink {
                XCTAssertEqual(.third, $0)
                expectJumping.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .second, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testJumpEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 98)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 98)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 98)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 98)
        
        map
            .moveY
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .start, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOnTheAirEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 98)
        
        map
            .moveY
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .second, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testUpStop() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 3)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 2)
        
        map
            .jumping
            .sink {
                XCTAssertEqual(.start, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .second, walking: .none, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testDirectionLeft() {
        let expectFace = expectation(description: "")
        let expectDirection = expectation(description: "")
        let expectMove = expectation(description: "")
        expectMove.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (6, 5)
        
        map
            .face
            .sink {
                XCTAssertEqual(.none, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .direction
            .sink {
                XCTAssertEqual(.left, $0)
                expectDirection.fulfill()
            }
            .store(in: &subs)
        
        map
            .moveX
            .sink { _ in
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .left, face: .walk1, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testDirectionRight() {
        let expectFace = expectation(description: "")
        let expectDirection = expectation(description: "")
        let expectMove = expectation(description: "")
        expectMove.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (6, 5)
        
        map
            .face
            .sink {
                XCTAssertEqual(.none, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .direction
            .sink {
                XCTAssertEqual(.right, $0)
                expectDirection.fulfill()
            }
            .store(in: &subs)
        
        map
            .moveX
            .sink { _ in
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .right, face: .walk1, direction: .left)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingLeft() {
        let expectFace = expectation(description: "")
        let expectMove = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (6, 5)
        
        map
            .face
            .sink {
                XCTAssertEqual(.walk2, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .moveX
            .sink {
                XCTAssertEqual(32 * 5, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .left, face: .walk1, direction: .left)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingLeftEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 0, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 1, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (1, 5)
        
        map
            .moveX
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .left, face: .walk1, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingRight() {
        let expectFace = expectation(description: "")
        let expectMove = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .face
            .sink {
                XCTAssertEqual(.walk2, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        map
            .moveX
            .sink {
                XCTAssertEqual(32 * 6, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .right, face: .walk1, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingRightNoGround() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .face
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .right, face: .walk1, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingLeftNoGround() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .face
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .left, face: .walk1, direction: .left)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingRightEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 198, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 199, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (198, 5)
        
        map
            .moveX
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .right, face: .walk1, direction: .left)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingLeft2() {
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 7, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (6, 5)
        
        map
            .face
            .sink {
                XCTAssertEqual(.walk1, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .left, face: .walk2, direction: .left)
        map.update(jumping: .none, walking: .left, face: .none, direction: .left)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingLeftJumping() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (6, 5)
        
        map
            .face
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .left, face: .jump, direction: .left)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingRight2() {
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 3, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 4, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (4, 5)
        
        map
            .face
            .sink {
                XCTAssertEqual(.walk1, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .right, face: .walk2, direction: .right)
        map.update(jumping: .none, walking: .right, face: .none, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingRightJumping() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .face
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .right, face: .jump, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingLeftCollision() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 6)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (6, 5)
        
        map
            .moveX
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .left, face: .walk1, direction: .left)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testWalkingRightCollision() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 6)
        
        map.load(ground: ground)
        map.characters[.cornelius] = (5, 5)
        
        map
            .moveX
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        map.update(jumping: .none, walking: .right, face: .walk1, direction: .right)
        
        waitForExpectations(timeout: 0.1)
    }
}
