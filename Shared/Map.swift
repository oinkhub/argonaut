import MapKit

final class Map: MKMapView, MKMapViewDelegate {
    var follow = true
    var refresh: (() -> Void)!
    private(set) var plan = [MKPointAnnotation]()
    let geocoder = CLGeocoder()
    
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
        guard follow else { return }
        var region = self.region
        region.center = didUpdate.coordinate
        setRegion(region, animated: true)
    }
    
    func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        guard let mark = viewFor as? MKPointAnnotation else { return view(for: viewFor) }
        var marker = dequeueReusableAnnotationView(withIdentifier: "mark")
        if marker == nil {
            marker = .init(annotation: mark, reuseIdentifier: "mark")
            marker!.image = NSImage(named: "mark")
            marker!.canShowCallout = true
            marker!.isDraggable = true
            marker!.leftCalloutAccessoryView = Label()
            (marker!.leftCalloutAccessoryView as! Label).font = .systemFont(ofSize: 16, weight: .bold)
            (marker!.leftCalloutAccessoryView as! Label).textColor = .white
        } else {
            marker!.annotation = mark
        }
        (marker!.leftCalloutAccessoryView as! Label).stringValue = "\(plan.firstIndex(of: mark)! + 1)"
        return marker
    }
    
    func mapView(_: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState) {
        if didChange == .ending {
            if let mark = annotationView.annotation as? MKPointAnnotation {
                locate(mark)
            }
        }
    }
    
    func add(_ mark: MKPointAnnotation) {
        plan.append(mark)
        addAnnotation(mark)
        selectAnnotation(mark, animated: true)
        locate(mark)
    }
    
    private func locate(_ mark: MKPointAnnotation) {
        geocoder.reverseGeocodeLocation(.init(latitude: mark.coordinate.latitude, longitude: mark.coordinate.longitude)) {
            mark.title = $1 == nil ? $0?.first?.name : .key("Map.mark")
            DispatchQueue.main.async { [weak self] in self?.refresh() }
        }
    }
}
