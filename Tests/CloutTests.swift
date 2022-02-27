import XCTest
@testable import Archivable
@testable import Master

final class CloudTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    private var model: Archive!
    
    override func setUp() async throws {
        cloud = .init()
        model = await cloud.model
    }
    
    func testSound() async {
        await cloud.toggle(sounds: false)
        
        model = await cloud.model
        XCTAssertFalse(model.settings.sounds)
    }
    
    func testLevelup() async {
        await cloud.levelup()
        
        model = await cloud.model
        XCTAssertEqual(1, model.level)
        
        await cloud.levelup()
        
        model = await cloud.model
        XCTAssertEqual(2, model.level)
    }
    
    func testTruffles() async {
        await cloud.update(truffles: 198)
        
        model = await cloud.model
        XCTAssertEqual(198, model.truffles)
    }
    
    func testRestart() async {
        await cloud.toggle(sounds: false)
        await cloud.levelup()
        await cloud.update(truffles: 198)
        
        await cloud.restart()
        
        model = await cloud.model
        XCTAssertEqual(0, model.level)
        XCTAssertEqual(0, model.truffles)
        XCTAssertFalse(model.settings.sounds)
    }
}
