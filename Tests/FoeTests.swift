import XCTest
import SpriteKit
@testable import Master

final class FoeTests: XCTestCase {
    private var game: Game!
    private var foes: SKNode!
    
    override func setUp() {
        game = .init()
    }
    
    func testAddLizards() {
        foes = .init()
        
        [CGPoint(x: 300, y: 300),
         .init(x: 100, y: 100),
         .init(x: 1000, y: 1000),
         .init(x: 234, y: 645)]
            .map {
                let foe = SKNode()
                foe.position = $0
                return foe
            }
            .forEach {
                foes.addChild($0)
            }
        
        game.load(lizards: foes)
        XCTAssertEqual(.init(x: 300, y: 300), game.items[.lizard(foes.children.first!)])
    }
}
