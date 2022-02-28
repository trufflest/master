import Foundation
import Archivable

extension Cloud where Output == Archive {
    public func levelup() async {
        model.level += 1
        await stream()
    }
    
    public func update(truffles: UInt16) async {
        guard model.truffles != truffles else { return }
        model.truffles = truffles
        await stream()
    }
    
    public func restart() async {
        model.level = 1
        model.truffles = 0
        await stream()
    }
    
    public func toggle(sounds: Bool) async {
        guard model.settings.sounds != sounds else { return }
        model.settings = model.settings.with(sounds: sounds)
        await stream()
    }
}
