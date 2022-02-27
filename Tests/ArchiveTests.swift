import XCTest
@testable import Archivable
@testable import Master

final class ArchiveTests: XCTestCase {
    private var archive: Archive!
    
    override func setUp() {
        archive = .init()
    }
    
    func testParse() async {
        archive = await Archive.prototype(data: archive.compressed)
        archive.level = 200
        archive.truffles = 32324
        archive.settings = archive.settings.with(sounds: false)

        archive = await Archive.prototype(data: archive.compressed)
        XCTAssertEqual(200, archive.level)
        XCTAssertEqual(32324, archive.truffles)
        XCTAssertFalse(archive.settings.sounds)
    }
}
