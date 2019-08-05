import Argonaut
import MapKit

final class Tiler: MKTileOverlay {
    private let cart: Cart
    
    init(_ cart: Cart) {
        self.cart = cart
        super.init(urlTemplate: "{z}-{x}.{y}")
        canReplaceMapContent = true
        tileSize = .init(width: 512, height: 512)
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        result(cart.map[url(forTilePath: at).path], nil)
    }
}
