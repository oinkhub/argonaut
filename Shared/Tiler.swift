import Argonaut
import MapKit

final class Tiler: MKTileOverlay {
    fileprivate let cart: Cart
    
    init(_ cart: Cart) {
        self.cart = cart
        super.init(urlTemplate: nil)
        tileSize = .init(width: Argonaut.tile * 2, height: Argonaut.tile * 2)
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        cart.tile(at.x, at.y) {
            result($0, nil)
        }
    }
}
