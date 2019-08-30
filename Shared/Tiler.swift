import Argonaut
import MapKit

final class Tiler: MKTileOverlay {
    fileprivate let cart: Cart
    
    init(_ cart: Cart) {
        self.cart = cart
        super.init(urlTemplate: nil)
        tileSize = .init(width: Argonaut.tile * 2, height: Argonaut.tile * 2)
        canReplaceMapContent = true
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        cart.tile(at.x, at.y) {
            print($0)
            result($0, nil)
        }
    }
}

final class Tiler2: MKOverlayRenderer {
    private let tile = Argonaut.tile * 2
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let tiler = overlay as! Tiler
        let zoom = Double(zoomScale) / tile

        tiler.cart.tile(Int(mapRect.minX * zoom), Int(mapRect.minY * zoom)) {

            if let data = $0 {
            //            let image = UIImage(data: data)
            //            if image == nil {
            //                print(data.count)
            //            }
            //            image?.draw(in: rect(for: mapRect))
            } else {
                print("data is nil")
            }
        }
    }
}
