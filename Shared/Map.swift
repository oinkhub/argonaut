import MapKit

final class Map: MKMapView, MKMapViewDelegate, CLLocationManagerDelegate {
    private let location = CLLocationManager()
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isRotateEnabled = false
        isPitchEnabled = false
        showsBuildings = true
        showsPointsOfInterest = true
        showsCompass = true
        showsScale = false
        showsTraffic = false
        showsUserLocation = true
        mapType = .standard
        delegate = self
        location.delegate = self
        
        var region = MKCoordinateRegion()
        region.center = userLocation.coordinate
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        setRegion(region, animated: false)
        
        status()
    }
    
    func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        var region = self.region
        region.center = didUpdate.coordinate
        setRegion(region, animated: true)
    }
    
    func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) { status() }

    private func status() {
        switch CLLocationManager.authorizationStatus() {
        case .denied: app.alert(.key("Error"), message: .key("Error.location"))
        case .notDetermined:
            if #available(macOS 10.14, *) {
                location.requestLocation()
            } else {
                location.startUpdatingLocation()
            }
        default: break
        }
    }
}
