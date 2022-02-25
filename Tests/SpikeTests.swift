import XCTest
import SpriteKit
import Combine
@testable import Master

final class SpikeTests: XCTestCase {
    private var game: Game!
    private var subs = Set<AnyCancellable>()
    private var spikes: SKNode!
    
    override func setUp() {
        spikes = .init()
        
        [CGPoint(x: 300, y: 300),
         .init(x: 100, y: 100),
         .init(x: 101, y: 101),
         .init(x: 234, y: 645)]
            .map {
                let spike = SKNode()
                spike.position = $0
                return spike
            }
            .forEach {
                spikes.addChild($0)
            }
        
        game = .init()
        game.load(spikes: spikes)
    }
    
    func testLoad() {
        XCTAssertEqual(4, game.items.count)
        XCTAssertTrue(game.items.contains {
            $0.1 == .init(x: 234, y: 645)
        })
    }
    
    func testContact() {
        let expectState = expectation(description: "")
        let expectFace = expectation(description: "")
        
        game.items[.cornelius] = .init(x: 234 - (14 - 1) - 7,
                                       y: 645 - 16 - (14 - 1) - 9)
        
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
                                       y: 645 - 16 - 14 - 9)
        
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
