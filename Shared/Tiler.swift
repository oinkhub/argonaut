import Argonaut
import MapKit

final class Tiler: MKTileOverlay {
    private var fallback: Data!
    private let cart: Cart
    
    deinit { print("tiler gone") }
    init(_ cart: Cart) {
        self.cart = cart
        super.init(urlTemplate: nil)
        fallback = outside
        tileSize = .init(width: Argonaut.tile * 2, height: Argonaut.tile * 2)
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        print("\(at.x), \(at.y), \(at.z)")
        cart.tile(at.x, at.y, at.z) { [weak self] in
            result($0 ?? self?.fallback, nil)
        }
    }
}
