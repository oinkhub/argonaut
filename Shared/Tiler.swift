import Argonaut
import MapKit

final class Tiler: MKTileOverlay {
    private let cart: Cart
    
    init(_ cart: Cart) {
        self.cart = cart
        super.init(urlTemplate: nil)
        canReplaceMapContent = true
        tileSize = .init(width: 2048, height: 2048)
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        print("\(at.z)-\(at.x).\(at.y)")
        result(cart.tile(at.z, x: at.x, y: at.y), nil)
    }
}
