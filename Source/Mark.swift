import MapKit

public final class Mark: NSObject, MKAnnotation {
    public weak var path: Plan.Path!
    public var coordinate: CLLocationCoordinate2D { get { .init(latitude: path.latitude, longitude: path.longitude) } }
}
