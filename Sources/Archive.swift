import Foundation
import Archivable

public struct Archive: Arch {
    public var timestamp: UInt32
    public internal(set) var level: UInt8
    public internal(set) var truffles: UInt16
    public internal(set) var settings: Settings
    
    public var data: Data {
        .init()
        .adding(level)
        .adding(truffles)
        .adding(settings)
    }
    
    public init() {
        timestamp = 0
        truffles = 0
        level = 1
        settings = .init()
    }
    
    public init(version: UInt8, timestamp: UInt32, data: Data) async {
        self.timestamp = timestamp
        var data = data
        level = data.number()
        truffles = data.number()
        settings = .init(data: &data)
    }
}
