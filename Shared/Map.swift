import MapKit

final class Map: MKMapView, MKMapViewDelegate {
    var refresh: (() -> Void)!
    private(set) var plan = [Route]()
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
        region.span.latitudeDelta = 0.05
        region.span.longitudeDelta = 0.05
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
            marker!.subviews.compactMap({ $0 as? Callout }).forEach { $0.remove() }
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
    
    func mapView(_: MKMapView, rendererFor: MKOverlay) -> MKOverlayRenderer {
        if let tiler = rendererFor as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tiler)
        } else if let polyline = rendererFor as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineWidth = 8
            renderer.strokeColor = NSColor.halo.withAlphaComponent(0.3)
            renderer.lineCap = .round
            return renderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_: MKMapView, didDeselect: MKAnnotationView) { didDeselect.subviews.compactMap({ $0 as? Callout }).forEach { $0.remove() } }
    
    func mapView(_: MKMapView, didSelect: MKAnnotationView) {
        if didSelect.annotation is MKUserLocation {
            Callout.User(didSelect)
        } else {
            Callout.Item(didSelect, index: "\(plan.firstIndex(where: { $0.mark === didSelect.annotation as! Mark })! + 1)")
        }
    }
    
    func remove(_ route: Route) {
        selectedAnnotations.forEach { deselectAnnotation($0, animated: true) }
        removeAnnotation(route.mark)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let index = self.plan.firstIndex(where: { $0 === route }) else { return }
            self.removeOverlays(route.path.map({ $0.polyline }))
            if index > 0 {
                if index < self.plan.count - 1 {
                    self.direction(self.plan[index - 1], destination: self.plan[index + 1].mark)
                } else {
                    self.removeOverlays(self.plan[index - 1].path.map({ $0.polyline }))
                }
            }
            self.plan.remove(at: index)
            DispatchQueue.main.async { [weak self] in self?.refresh() }
        }
    }
    
    @objc func centre() {
        var region = self.region
        region.center = userLocation.coordinate
        setRegion(region, animated: true)
        selectAnnotation(userLocation, animated: true)
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
        if !plan.contains(where: { $0.mark.coordinate.latitude == coordinate.latitude && $0.mark.coordinate.longitude == coordinate.longitude }) {
            let route = Route(coordinate)
            plan.append(route)
            addAnnotation(route.mark)
            selectAnnotation(route.mark, animated: true)
            locate(route.mark)
        }
    }
    
    @objc func follow() {
        _follow.toggle()
        if _follow {
            centre()
        }
    }
    
    private func locate(_ mark: Mark) {
        geocoder.reverseGeocodeLocation(mark.location) {
            if $1 == nil {
                mark.name = $0?.first?.name ?? .key("Map.mark")
                DispatchQueue.main.async { [weak self, weak mark] in
                    guard let self = self, let mark = mark else { return }
                    self.view(for: mark)?.subviews.compactMap({ $0 as? Callout.Item }).first?.refresh(mark.name)
                    self.refresh()
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        guard let self = self else { return }
                        if let index = self.plan.firstIndex(where: { $0.mark === mark }) {
                            if index > 0 {
                                self.direction(self.plan[index - 1], destination: mark)
                            }
                            if index < self.plan.count - 1 {
                                self.direction(self.plan[index], destination: self.plan[index + 1].mark)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func direction(_ route: Route, destination: Mark) {
        removeOverlays(route.path.map({ $0.polyline }))
        route.path = []
        DispatchQueue.main.async { [weak self] in
            self?.direction(.walking, route: route, destination: destination)
            self?.direction(.automobile, route: route, destination: destination)
        }
    }
    
    private func direction(_ transport: MKDirectionsTransportType, route: Route, destination: Mark) {
        let request = MKDirections.Request()
        request.transportType = transport
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: route.mark.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate, addressDictionary: nil))
        MKDirections(request: request).calculate { [weak self] in
            if $1 == nil, let paths = $0?.routes {
                route.path.append(contentsOf: paths)
                self?.addOverlays(paths.map { $0.polyline }, level: .aboveLabels)
            }
        }
    }
}
