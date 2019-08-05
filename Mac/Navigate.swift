import Argonaut
import MapKit

final class Navigate: World {
    init(_ cart: Cart) {
        super.init()
        map.addOverlay(Tiler(cart), level: .aboveLabels)
        tools.bottomAnchor.constraint(equalTo: _out.bottomAnchor).isActive = true
    }
}
