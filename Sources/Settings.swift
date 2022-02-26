import Foundation
import Archivable

public struct Settings: Storable {
    public let sounds: Bool
    
    public var data: Data {
        .init()
        .adding(sounds)
    }
    
    public init(data: inout Data) {
        sounds = data.bool()
    }
    
    init() {
        self.init(sounds: true)
    }
    
    private init(sounds: Bool) {
        self.sounds = sounds
    }
    
    func with(sounds: Bool) -> Self {
        .init(sounds: sounds)
    }
}
