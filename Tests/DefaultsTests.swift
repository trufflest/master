import XCTest
@testable import Master

final class DefaultsTests: XCTestCase {
    override func setUp() {
        UserDefaults.standard.removeObject(forKey: Defaults.rated.rawValue)
        UserDefaults.standard.removeObject(forKey: Defaults.created.rawValue)
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
}
