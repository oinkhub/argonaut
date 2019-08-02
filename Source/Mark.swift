import MapKit

public final class Mark: NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D { get { .init(latitude: path.latitude, longitude: path.longitude) } set { path.latitude = newValue.latitude; path.longitude = newValue.longitude }}
    public private(set) weak var path: Plan.Path!
    
    public init(_ path: Plan.Path) {
        self.path = path
        super.init()
    }
}
