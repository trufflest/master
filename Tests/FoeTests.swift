import XCTest
import SpriteKit
@testable import Master

final class FoeTests: XCTestCase {
    private var game: Game!
    
    override func setUp() {
        game = .init()
    }
    
    func testAdd() {
        let sprite = SKNode()
        sprite.position = .init(x: 33, y: 44)
        game.add(lizard: sprite)
        XCTAssertEqual(.init(x: 33, y: 44), game.items[.lizard(sprite)])
    }
}
