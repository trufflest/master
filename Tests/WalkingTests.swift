import XCTest
import SpriteKit
import Combine
@testable import Master

final class WalkingTests: XCTestCase {
    private var group: SKTileGroup!
    private var ground: SKTileMapNode!
    private var game: Game!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        group = .init(tileDefinition: .init())
        ground = .init(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                       columns: 200,
                       rows: 100,
                       tileSize: .init(width: 32, height: 32))
        game = .init()
        subs = .init()
    }

    func testDirection() {
        let expectFace = expectation(description: "")
        let expectDirection = expectation(description: "")
        let expectMove = expectation(description: "")
        expectMove.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 6, y: 32 * 5)
        
        game
            .face
            .sink {
                XCTAssertEqual(.none, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        game
            .direction
            .sink {
                XCTAssertEqual(.left, $0)
                expectDirection.fulfill()
            }
            .store(in: &subs)
        
        game
            .moveX
            .sink { _ in
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        game.walk(walking: .left, face: .walk1(0), direction: .right)
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testWalking() {
        let expectFace = expectation(description: "")
        let expectMove = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 6, y: 32 * 5)
        
        game
            .face
            .sink {
                XCTAssertEqual(.walk1(1), $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        game
            .moveX
            .sink {
                XCTAssertEqual(188, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        game.walk(walking: .left, face: .walk1(0), direction: .left)
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testWalkingFace() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 6, y: 32 * 5)
        
        game
            .face
            .sink {
                XCTAssertEqual(.walk2(0), $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.walk(walking: .left, face: .walk1(2), direction: .left)
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testWalkingLeftEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 0, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 8, y: 32 * 5)
        
        game
            .moveX
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.walk(walking: .left, face: .walk1(0), direction: .left)
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testWalkingNoGround() {
        let expectFace = expectation(description: "")
        expectFace.isInverted = true
        let expectMove = expectation(description: "")
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 100, y: 100)
        
        game
            .face
            .sink { _ in
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        game
            .moveX
            .sink {
                XCTAssertEqual(104, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        game.walk(walking: .right, face: .walk1(0), direction: .right)
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testWalkingRightEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 199, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 199 + 24, y: 32 * 5)
        
        game
            .moveX
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.walk(walking: .right, face: .walk1(0), direction: .right)
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testWalkingCollision() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 5)
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 6, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 6, y: 32 * 5)
        
        game
            .moveX
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.walk(walking: .left, face: .walk1(0), direction: .left)
        
        waitForExpectations(timeout: 0.05)
    }
}
