import MapKit

final class MockRoute: MKRoute {
    override var polyline: MKPolyline { return line }
    private let line: MKPolyline
    
    init(_ coordinates: [(CLLocationDegrees, CLLocationDegrees)]) {
        line = MKPolyline(coordinates: coordinates.map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }, count: coordinates.count)
    }
}
