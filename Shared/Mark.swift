import MapKit

final class Mark: NSObject, MKAnnotation {
    var name = ""
    var location = CLLocation()
    var coordinate: CLLocationCoordinate2D { get { return location.coordinate } set { location = .init(latitude: newValue.latitude, longitude: newValue.longitude) } }
}
