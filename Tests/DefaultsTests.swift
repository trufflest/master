import XCTest
@testable import Master

final class DefaultsTests: XCTestCase {
    override func setUp() {
        UserDefaults.standard.removeObject(forKey: Defaults.rated.rawValue)
        UserDefaults.standard.removeObject(forKey: Defaults.created.rawValue)
        UserDefaults.standard.removeObject(forKey: Defaults.purchases.rawValue)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Defaults.rated.rawValue)
        UserDefaults.standard.removeObject(forKey: Defaults.created.rawValue)
    }
    
    func testFirstTime() {
        XCTAssertNil(UserDefaults.standard.object(forKey: Defaults.created.rawValue))
        XCTAssertFalse(Defaults.rate)
        XCTAssertNotNil(UserDefaults.standard.object(forKey: Defaults.created.rawValue))
    }
    
    func testRate() {
        UserDefaults.standard.setValue(Calendar.current.date(byAdding: .day, value: -6, to: .now)!, forKey: Defaults.created.rawValue)
        XCTAssertFalse(Defaults.rate)
        XCTAssertFalse(Defaults.hasRated)
        UserDefaults.standard.setValue(Calendar.current.date(byAdding: .day, value: -7, to: .now)!, forKey: Defaults.created.rawValue)
        XCTAssertTrue(Defaults.rate)
        XCTAssertTrue(Defaults.hasRated)
        XCTAssertFalse(Defaults.rate)
    }
    
    func testPurchases() {
        XCTAssertFalse(Defaults.has(level: 5))
        Defaults.purchase(level: 5)
        Defaults.purchase(level: 5)
        XCTAssertEqual(1, Defaults.perks.count)
        XCTAssertTrue(Defaults.has(level: 5))
        XCTAssertFalse(Defaults.has(level: 4))
        Defaults.remove(level: 5)
        XCTAssertFalse(Defaults.has(level: 5))
        XCTAssertTrue(Defaults.perks.isEmpty)
    }
    
    func testHasLevel() {
        XCTAssertTrue(Defaults.has(level: 0))
        XCTAssertTrue(Defaults.has(level: 1))
    }
}
