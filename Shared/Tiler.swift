import Argonaut
import MapKit

final class Tiler: MKTileOverlay {
    private let cart: Cart
    
    init(_ cart: Cart) {
        self.cart = cart
        super.init(urlTemplate: nil)
        canReplaceMapContent = true
        tileSize = .init(width: Argonaut.tile * 2, height: Argonaut.tile * 2)
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        result(cart.tile(at.z, x: at.x, y: at.y), nil)
    }
}
