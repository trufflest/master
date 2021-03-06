import XCTest
import SpriteKit
import Combine
@testable import Master

final class FoeTests: XCTestCase {
    private var game: Game!
    private var foes: SKNode!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        game = .init()
        subs = .init()
        foes = .init()
        
        let group = SKTileGroup(tileDefinition: .init())
        let ground = SKTileMapNode(tileSet: .init(tileGroups: [group], tileSetType: .grid),
                                  columns: 200,
                                  rows: 100,
                                  tileSize: .init(width: 32, height: 32))
        
        game.load(ground: ground)
        
        [CGPoint(x: 300, y: 300),
         .init(x: 100, y: 100),
         .init(x: 101, y: 101),
         .init(x: 234, y: 645)]
            .map {
                let foe = Character()
                foe.position = $0
                return foe
            }
            .forEach {
                foes.addChild($0)
            }
        
        game.load(lizards: foes)
    }
    
    func testAddLizard() {
        XCTAssertTrue(game.items.contains(where: {
            $0.value.x == 234 && $0.value.y == 645
        }))
        
        if case let .foe(foe, _) = game.items.first?.key {
            XCTAssertEqual(.lizard, foe)
        } else {
            XCTFail()
        }
    }
    
    func testContact() {
        let expectState = expectation(description: "")
        let expectFace = expectation(description: "")
        
        game.items[.cornelius] = .init(x: 234 - (12 - 1) - 12,
                                       y: 645 - (12 - 1) - 12)
        
        game
            .state
            .sink {
                XCTAssertEqual(.dead, $0)
                expectState.fulfill()
            }
            .store(in: &subs)
        
        game
            .face
            .sink {
                XCTAssertEqual(.dead, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        game.contact()
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testNoContact() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        game.items[.cornelius] = .init(x: 234,
                                       y: 645 - 14 - 14)
        
        game
            .state
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.contact()
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testDoubleContact() {
        let expectState = expectation(description: "")
        let expectFace = expectation(description: "")
        
        game.items[.cornelius] = .init(x: 100,
                                       y: 100)
        
        game
            .state
            .sink {
                XCTAssertEqual(.dead, $0)
                expectState.fulfill()
            }
            .store(in: &subs)
        
        game
            .face
            .sink {
                XCTAssertEqual(.dead, $0)
                expectFace.fulfill()
            }
            .store(in: &subs)
        
        game.contact()
        
        waitForExpectations(timeout: 0.05)
    }
}
