import Argonaut
import MapKit

final class Navigate: World {
    init(_ id: String) {
        super.init()

        map.addOverlay(Tiler(id), level: .aboveLabels)
        tools.bottomAnchor.constraint(equalTo: _out.bottomAnchor).isActive = true
    }
}
