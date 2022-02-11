import SpriteKit

public struct Map {
    public private(set) var area: [[Content]]
    
    init(ground: SKTileMapNode) {
        area = (0 ..< ground.numberOfColumns).map { x in
            (0 ..< ground.numberOfRows).map { y in
                ground.tileDefinition(atColumn: x, row: y) == nil ? .empty : .ground
            }
        }
    }
}
