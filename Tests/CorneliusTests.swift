import XCTest
import SpriteKit
@testable import Master

final class CorneliusTests: XCTestCase {
    private var game: Game!
    
    override func setUp() {
        game = .init()
    }
    
    func testAdd() {
        let sprite = SKNode()
        sprite.position = .init(x: 33, y: 44)
        game.add(cornelius: sprite)
        XCTAssertEqual(.init(x: 33, y: 44), game.items[.cornelius])
    }
}
