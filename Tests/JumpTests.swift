import XCTest
import SpriteKit
import Combine
@testable import Master

final class JumpTests: XCTestCase {
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

    func testJump() {
        let expectFace = expectation(description: "")
        let expectMove = expectation(description: "")
        let expectJumping = expectation(description: "")
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 1)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 32 * 5, y: 32 * 2)
        
        game
            .face
            .sink {
                XCTAssertEqual(.jump, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        game
            .moveY
            .sink {
                XCTAssertEqual(72, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        game
            .jumping
            .sink {
                XCTAssertEqual(.counter(0), $0)
                expectJumping.fulfill()
            }
            .store(in: &subs)
        
        game.jump(jumping: .ready, face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOnTheUp() {
        let expectMove = expectation(description: "")
        let expectJumping = expectation(description: "")
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 100, y: 100)

        game
            .moveY
            .sink {
                XCTAssertEqual(108, $0)
                expectMove.fulfill()
            }
            .store(in: &subs)
        
        game
            .jumping
            .sink {
                XCTAssertEqual(.counter(1), $0)
                expectJumping.fulfill()
            }
            .store(in: &subs)
        
        game.jump(jumping: .counter(0), face: .jump)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testJumpEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        ground.setTileGroup(group, andTileDefinition: .init(), forColumn: 5, row: 98)
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 5 * 32, y: 99 * 32)
        
        game
            .moveY
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.jump(jumping: .ready, face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOnTheAirEdge() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 5 * 32, y: 99 * 32)
        
        game
            .moveY
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.jump(jumping: .counter(0), face: .jump)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testUpStop() {
        let expect = expectation(description: "")
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 100, y: 100)
        
        game
            .jumping
            .sink {
                XCTAssertEqual(.over, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.jump(jumping: .counter(12), face: .jump)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testFlyingFace() {
        let expect = expectation(description: "")
        
        game.load(ground: ground)
        game.items[.cornelius] = .init(x: 100, y: 100)
        
        game
            .face
            .sink {
                XCTAssertEqual(.jump, $0)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.jump(jumping: .counter(3), face: .none)
        
        waitForExpectations(timeout: 0.1)
    }
}
