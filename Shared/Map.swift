import MapKit

final class Map: MKMapView, MKMapViewDelegate {
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
        
        var region = MKCoordinateRegion()
        region.center = userLocation.coordinate
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        setRegion(region, animated: false)
    }
    
    func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        var region = self.region
        region.center = didUpdate.coordinate
        setRegion(region, animated: true)
    }
    
    func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        guard let mark = viewFor as? MKPointAnnotation else { return view(for: viewFor) }
        guard let marker = dequeueReusableAnnotationView(withIdentifier: "mark")
        else {
            let marker = MKPinAnnotationView(annotation: mark, reuseIdentifier: "mark")
            marker.pinTintColor = .black
            marker.animatesDrop = true
            marker.canShowCallout = true
            return marker
        }
        marker.annotation = mark
        return marker
    }
}
