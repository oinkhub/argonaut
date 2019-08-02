import Argonaut
import MapKit

final class Mark: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D { get { .init(latitude: path.latitude, longitude: path.longitude) } set { path.latitude = newValue.latitude; path.longitude = newValue.longitude }}
    private(set) weak var path: Plan.Path!
    
    init(_ path: Plan.Path) {
        self.path = path
        super.init()
    }
}
