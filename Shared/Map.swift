import MapKit

final class Map: MKMapView, MKMapViewDelegate {
    var follow = true
    var refresh: (() -> Void)!
    private(set) var plan = [Mark]()
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
        setRegion(region, animated: false)
    }
    
    func mapView(_: MKMapView, didAdd: [MKAnnotationView]) {
        didAdd.first(where: { $0.annotation is MKUserLocation })?.canShowCallout = false
    }
    
    func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        guard let mark = viewFor as? Mark else { return view(for: viewFor) }
        var marker = dequeueReusableAnnotationView(withIdentifier: "mark")
        if marker == nil {
            marker = .init(annotation: mark, reuseIdentifier: "mark")
            marker!.image = NSImage(named: "mark")
            marker!.isDraggable = true
        } else {
            marker!.annotation = mark
            marker!.subviews.forEach { $0.removeFromSuperview() }
        }
        return marker
    }
    
    func mapView(_: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState) {
        if didChange == .ending {
            if let mark = annotationView.annotation as? Mark {
                locate(mark)
            }
        }
    }
    
    func mapView(_: MKMapView, didDeselect: MKAnnotationView) { didDeselect.subviews.forEach { $0.removeFromSuperview() } }
    
    func mapView(_: MKMapView, didSelect: MKAnnotationView) {
        guard let mark = didSelect.annotation as? Mark else { return }
        Callout(didSelect, index: "\(plan.firstIndex(of: mark)! + 1)")
    }
    
    func add(_ mark: Mark) {
        if let last = plan.last {
            mark.distance = mark.distance(from: last)
        }
        plan.append(mark)
        addAnnotation(mark)
        selectAnnotation(mark, animated: true)
        locate(mark)
    }
    
    private func locate(_ mark: Mark) {
        geocoder.reverseGeocodeLocation(mark) { found, _ in
            mark.name = found?.first?.name ?? .key("Map.mark")
            DispatchQueue.main.async { [weak self] in
                self?.refresh()
                self?.view(for: mark)?.subviews.compactMap({ $0 as? Callout }).first?.refresh(mark.name)
            }
        }
    }
}
