import Argonaut
import MapKit

final class Map: MKMapView, MKMapViewDelegate {
    var refresh: (() -> Void)!
    private(set) var _follow = true
    private(set) var _walking = true
    private(set) var _driving = true
    let plan = Plan()
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
        } else if let line = rendererFor as? Line {
            return Liner(line)
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_: MKMapView, didDeselect: MKAnnotationView) { didDeselect.subviews.compactMap({ $0 as? Callout }).forEach { $0.remove() } }
    
    func mapView(_: MKMapView, didSelect: MKAnnotationView) {
        if let mark = didSelect.annotation as? Mark {
            Callout.Item(didSelect, index: "\(plan.path.firstIndex { $0 === mark.path }! + 1)")
        } else {
            Callout.User(didSelect)
        }
    }
    
    func focus(_ coordinate: CLLocationCoordinate2D) {
        var region = self.region
        region.center = coordinate
        setRegion(region, animated: true)
    }
    
    func add(_ coordinate: CLLocationCoordinate2D) {
        if !plan.path.contains(where: { $0.latitude == coordinate.latitude && $0.longitude == coordinate.longitude }) {
            let path = Plan.Path()
            path.latitude = coordinate.latitude
            path.longitude = coordinate.longitude
            plan.path.append(path)
            let mark = Mark(path)
            addAnnotation(mark)
            selectAnnotation(mark, animated: true)
            locate(mark)
        }
    }
    
    func remove(_ path: Plan.Path) {
        selectedAnnotations.forEach { deselectAnnotation($0, animated: true) }
        removeAnnotations(annotations.compactMap { ($0 as? Mark)?.path === path ? $0 : nil } )
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let index = self.plan.path.firstIndex(where: { $0 === path }) else { return }
            self.remove(overlays: path)
            if index > 0 {
                if index < self.plan.path.count - 1 {
                    self.direction(self.plan.path[index - 1], destination: self.plan.path[index + 1])
                } else {
                    self.remove(overlays: self.plan.path[index - 1])
                }
            }
            self.plan.path.remove(at: index)
            DispatchQueue.main.async { [weak self] in self?.refresh() }
        }
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
        add(convert(.init(x: bounds.midX, y: bounds.midY + 18.5), toCoordinateFrom: self))
    }
    
    @objc func follow() {
        _follow.toggle()
        if _follow {
            focus(userLocation.coordinate)
            selectAnnotation(userLocation, animated: true)
        }
    }
    
    @objc func walking() {
        _walking.toggle()
        filter()
    }
    
    @objc func driving() {
        _driving.toggle()
        filter()
    }
    
    private func locate(_ mark: Mark) {
        geocoder.reverseGeocodeLocation(.init(latitude: mark.path.latitude, longitude: mark.path.longitude)) {
            if $1 == nil {
                mark.path.name = $0?.first?.name ?? .key("Map.mark")
                DispatchQueue.main.async { [weak self, weak mark] in
                    guard let self = self, let mark = mark else { return }
                    self.view(for: mark)?.subviews.compactMap({ $0 as? Callout.Item }).first?.refresh(mark.path.name)
                    self.refresh()
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        guard let self = self else { return }
                        if let index = self.plan.path.firstIndex(where: { $0 === mark.path }) {
                            if index > 0 {
                                self.direction(self.plan.path[index - 1], destination: mark.path)
                            }
                            if index < self.plan.path.count - 1 {
                                self.direction(self.plan.path[index], destination: self.plan.path[index + 1])
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func direction(_ path: Plan.Path, destination: Plan.Path) {
        removeOverlays(overlays.filter({ ($0 as? Line)?.path === path }))
        path.options = []
        DispatchQueue.main.async { [weak self] in
            self?.direction(.walking, path: path, destination: destination)
            self?.direction(.automobile, path: path, destination: destination)
        }
    }
    
    private func direction(_ transport: MKDirectionsTransportType, path: Plan.Path, destination: Plan.Path) {
        let request = MKDirections.Request()
        request.transportType = transport
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: path.latitude, longitude: path.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: destination.latitude, longitude: destination.longitude), addressDictionary: nil))
        MKDirections(request: request).calculate { [weak self] in
            if $1 == nil, let paths = $0?.routes {
                path.options = paths.map {
                    let option = Plan.Option()
                    option.mode = $0.transportType == .walking ? .walking : .driving
                    option.distance = $0.distance
                    option.duration = $0.expectedTravelTime
                    option.points = UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { ($0.coordinate.latitude, $0.coordinate.longitude) }
                    return option
                }
                self?.refresh()
                if (transport == .automobile && self?._driving == true) || (transport == .walking && self?._walking == true) {
                    self?.addOverlays(path.options.map { Line(path, option: $0) }, level: .aboveRoads)
                }
            }
        }
    }
    
    private func filter() {
        removeOverlays(overlays)
        addOverlays(plan.path.flatMap { path in path.options.compactMap { $0.mode == .walking && _walking || $0.mode == .driving && _driving ? Line(path, option: $0) : nil } }, level: .aboveRoads)
    }
    
    private func remove(overlays: Plan.Path) {
        removeOverlays(self.overlays.compactMap { ($0 as? Line)?.path === overlays ? $0 : nil } )
    }
}
