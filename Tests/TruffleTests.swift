import XCTest
import SpriteKit
import Combine
@testable import Master

final class TruffleTests: XCTestCase {
    private var game: Game!
    private var subs = Set<AnyCancellable>()
    private var truffles: SKNode!
    
    override func setUp() {
        truffles = .init()
        
        [CGPoint(x: 300, y: 300),
         .init(x: 100, y: 100),
         .init(x: 1000, y: 1000),
         .init(x: 234, y: 645)]
            .map {
                let truffle = SKNode()
                truffle.position = $0
                return truffle
            }
            .forEach {
                truffles.addChild($0)
            }
        
        game = .init()
        game.load(truffles: truffles)
    }
    
    func testLoad() {
        XCTAssertEqual(4, game.items.count)
        XCTAssertTrue(game.items.contains {
            $0.1 == .init(x: 234, y: 645)
        })
    }
    
    func testPickupBelow() {
        let expect = expectation(description: "")
        
        let truffle = game.items.first {
            $0.1 == .init(x: 234, y: 645)
        }!
        
        var node: SKNode!
        
        if case let .truffle(truffle) = truffle.key {
            node = truffle
        }
        
        XCTAssertNotNil(node.parent)
        
        game.items[.cornelius] = .init(x: 234 - (14 - 1) - 10,
                                       y: 645 - 16 - (14 - 1) - 10)
        XCTAssertEqual(5, game.items.count)
        
        game
            .truffle
            .sink {
                XCTAssertEqual(4, self.game.items.count)
                XCTAssertEqual(.init(x: 234, y: 645), $0.position)
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.contact()
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testNoContactBelow() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        game.items[.cornelius] = .init(x: 234,
                                       y: 645 - 16 - 14 - 10)
        
        game
            .truffle
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.contact()
        
        waitForExpectations(timeout: 0.05)
    }
    
    func testNoContactAbove() {
        let expect = expectation(description: "")
        expect.isInverted = true
        
        game.items[.cornelius] = .init(x: 234,
                                       y: 645 + (14 - 1) + 10)
        
        game
            .truffle
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        game.contact()
        
        waitForExpectations(timeout: 0.05)
    }
}
