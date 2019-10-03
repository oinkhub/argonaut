import Argo
import MapKit

final class Mark: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D { get { .init(latitude: path.latitude, longitude: path.longitude) } set { path.latitude = newValue.latitude; path.longitude = newValue.longitude }}
    private(set) weak var path: Path!
    
    init(_ path: Path) {
        self.path = path
        super.init()
    }
}
