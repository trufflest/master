import XCTest
import SpriteKit
import Combine
@testable import Master

final class GravityTests: XCTestCase {
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
    
    func testFalling() {
        let expect = expectation(description: "")
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 100, y: 100)
        
        game
            .moveY
            .sink {
                XCTAssertEqual(92, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.gravity(jumping: .ready, walking: .none, face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testCornerFalling() {
        let expect = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 6, y: 32 * 5)
        
        game
            .moveY
            .sink {
                XCTAssertEqual(152, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.gravity(jumping: .ready, walking: .none, face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testCornerNotFalling() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 6 - 1, y: 32 * 5)
        
        game
            .moveY
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.gravity(jumping: .ready, walking: .none, face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testFallingEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 100, y: 8)
        
        game
            .moveY
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.gravity(jumping: .ready, walking: .none, face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOverFell() {
        let expect = expectation(description: "")
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 100, y: 8)
        
        game
            .state
            .sink {
                XCTAssertEqual(.dead, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.gravity(jumping: .ready, walking: .none, face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testGrounding() {
        let expectFace = expectation(description: "")
        let expectJumping = expectation(description: "")
        let expectMoveY = expectation(description: "")
        expectMoveY.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 4)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 5, y: 32 * 5)
        
        game
            .face
            .sink {
                XCTAssertEqual(.none, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        game
            .jumping
            .sink {
                XCTAssertEqual(.ready, $0)
                expectJumping.fulfill()
            }
            .store(in: &subs)
        
        game
            .moveY
            .sink { _ in
                expectMoveY.fulfill()
            }
            .store(in: &subs)
        
        game.gravity(jumping: .over, walking: .none, face: .jump)
        
        waitForExpectations(timeout: 0.1)
    }
}
