import MapKit

final class Map: MKMapView, MKMapViewDelegate {
    var refresh: (() -> Void)!
    private(set) var plan = [Mark]()
    private var _follow = true
    private let geocoder = CLGeocoder()
    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in self?._follow = false }
    }
    
    func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        guard _follow else { return }
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
            marker!.centerOffset.y = -28
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
    
    func remove(_ mark: Mark) {
        selectedAnnotations.forEach { deselectAnnotation($0, animated: true) }
        plan.removeAll(where: { $0 === mark })
        removeAnnotation(mark)
    }
    
    @objc func centre() {
        var region = self.region
        region.center = userLocation.coordinate
        setRegion(region, animated: true)
    }
    
    @objc func `in`() {
        var region = self.region
        region.span.latitudeDelta *= 0.1
        region.span.longitudeDelta *= 0.1
        setRegion(region, animated: true)
    }
    
    @objc func out() {
        var region = self.region
        region.span.latitudeDelta = min(region.span.latitudeDelta / 0.1, 180)
        region.span.longitudeDelta = min(region.span.longitudeDelta / 0.1, 180)
        setRegion(region, animated: true)
    }
    
    @objc func up() {
        var region = self.region
        region.center.latitude = min(region.center.latitude + region.span.latitudeDelta / 2, 90)
        setRegion(region, animated: true)
    }
    
    @objc func down() {
        var region = self.region
        region.center.latitude = max(region.center.latitude - region.span.latitudeDelta / 2, -90)
        setRegion(region, animated: true)
    }
    
    @objc func left() {
        var region = self.region
        region.center.longitude = max(region.center.longitude - region.span.longitudeDelta / 2, -180)
        setRegion(region, animated: true)
    }
    
    @objc func right() {
        var region = self.region
        region.center.longitude = min(region.center.longitude + region.span.longitudeDelta / 2, 180)
        setRegion(region, animated: true)
    }
    
    @objc func pin() {
        guard !geocoder.isGeocoding else { return }
        let coordinate = convert(.init(x: frame.midX, y: frame.midY), toCoordinateFrom: self)
        if !plan.contains(where: { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }) {
            let mark = Mark()
            mark.coordinate = coordinate
            plan.append(mark)
            addAnnotation(mark)
            selectAnnotation(mark, animated: true)
            locate(mark)
        }
    }
    
    @objc func follow() {
        _follow.toggle()
        if _follow {
            centre()
        }
    }
    
    private func locate(_ mark: Mark) {
        geocoder.reverseGeocodeLocation(mark.location) { found, _ in
            mark.name = found?.first?.name ?? .key("Map.mark")
            DispatchQueue.main.async { [weak self] in
                self?.refresh()
                self?.view(for: mark)?.subviews.compactMap({ $0 as? Callout }).first?.refresh(mark.name)
            }
        }
    }
}
