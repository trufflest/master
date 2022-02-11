import SpriteKit

public struct Map {
    var characters: [Content : (Int, Int)]
    let area: [[Content]]
    private let size: CGFloat
    
    init(ground: SKTileMapNode) {
        size = ground.tileSize.width
        area = (0 ..< ground.numberOfColumns).map { x in
            (0 ..< ground.numberOfRows).map { y in
                ground.tileDefinition(atColumn: x, row: y) == nil ? .empty : .ground
            }
        }
        
        var y = 0
        let x = 2
        
        while area[x][y] == .ground {
            y += 1
        }
        
        characters = [.cornelius : (x, y)]
    }
    
    public subscript(_ content: Content) -> CGPoint {
        characters[content]
            .map {
                .init(x: .init($0.0) * size, y: .init($0.1) * size)
            }
        ?? .zero
    }
}
