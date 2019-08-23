import Argonaut
import MapKit

final class Map: MKMapView, MKMapViewDelegate {
    var refresh: (() -> Void)!
    var zoom: ((Bool) -> Void)?
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
        showsUserLocation = true
        mapType = .standard
        delegate = self
        
        var region = MKCoordinateRegion()
        region.center = userLocation.location == nil ? self.region.center : userLocation.coordinate
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        setRegion(region, animated: false)
    }
    
    func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        guard _follow else { return }
        var region = self.region
        region.center = didUpdate.coordinate
        setRegion(region, animated: false)
    }
    
    func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        switch viewFor {
        case let user as MKUserLocation:
            let heading = dequeueReusableAnnotationView(withIdentifier: "user") as? User ?? User(annotation: nil, reuseIdentifier: "user")
            heading.annotation = user
            heading.subviews.compactMap { $0 as? Callout }.forEach { $0.remove() }
            return heading
        case let mark as Mark:
            let marker = dequeueReusableAnnotationView(withIdentifier: Marker.id) as? Marker ?? Marker()
            marker.annotation = mark
            marker.index?.text = "\(plan.path.firstIndex { $0 === mark.path }! + 1)"
            return marker
        default: return nil
        }
    }
    
    func mapView(_: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState) {
        if didChange == .ending {
            if let mark = annotationView.annotation as? Mark {
                locate(mark)
            }
        }
    }
    
    func mapView(_: MKMapView, regionDidChangeAnimated: Bool) {
        zoom?(log2(visibleMapRect.width / Double(bounds.width / 100) ) < 14)
    }
    
    func mapView(_: MKMapView, rendererFor: MKOverlay) -> MKOverlayRenderer {
        if let tiler = rendererFor as? Tiler {
            return MKTileOverlayRenderer(tileOverlay: tiler)
        } else if let line = rendererFor as? Line {
            return Liner(line)
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_: MKMapView, didDeselect: MKAnnotationView) {
        didDeselect.isSelected = false
    }
    
    func mapView(_: MKMapView, didSelect: MKAnnotationView) { didSelect.isSelected = true }
    
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
        removeAnnotations(annotations.filter { ($0 as? Mark)?.path === path })
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let index = self.plan.path.firstIndex(where: { $0 === path }) else { return }
            self.removeOverlays(self.overlays.filter { ($0 as? Line)?.path === path } )
            if index > 0 {
                if index < self.plan.path.count - 1 {
                    self.direction(self.plan.path[index - 1], destination: self.plan.path[index + 1])
                } else {
                    self.removeOverlays(self.overlays.filter { ($0 as? Line)?.path === self.plan.path[index - 1] } )
                }
            }
            self.plan.path.remove(at: index)
            DispatchQueue.main.async { [weak self] in self?.refresh() }
        }
    }
    
    func merge(_ plan: Plan) {
        self.plan.path.append(contentsOf: plan.path)
        addAnnotations(plan.path.map { Mark($0) })
        filter()
    }
    
    @objc func pin() {
        guard !geocoder.isGeocoding else { return }
//        add(convert(.init(x: bounds.midX, y: bounds.midY + top), toCoordinateFrom: self))
    }
    
    @objc func follow() {
        _follow.toggle()
        if _follow {
            if annotations.contains(where: { $0 === userLocation }) {
                focus(userLocation.coordinate)
                selectAnnotation(userLocation, animated: true)
            }
        } else {
            selectedAnnotations.forEach { deselectAnnotation($0, animated: true) }
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
                    (self.view(for: mark) as? Marker)?.refresh()
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
        removeOverlays(overlays.filter { ($0 as? Line)?.path === path })
        path.options = []
        DispatchQueue.main.async { [weak self] in
            self?.direction(.walking, path: path, destination: destination)
            self?.direction(.automobile, path: path, destination: destination)
        }
    }
    
    private func direction(_ transport: MKDirectionsTransportType, path: Plan.Path, destination: Plan.Path) {
        let request = MKDirections.Request()
        request.transportType = transport
        request.source = .init(placemark: .init(coordinate: .init(latitude: path.latitude, longitude: path.longitude), addressDictionary: nil))
        request.destination = .init(placemark: .init(coordinate: .init(latitude: destination.latitude, longitude: destination.longitude), addressDictionary: nil))
        MKDirections(request: request).calculate { [weak self] in
            if $1 == nil, let paths = $0?.routes {
                let options = paths.map {
                    let option = Plan.Option()
                    option.mode = $0.transportType == .walking ? .walking : .driving
                    option.distance = $0.distance
                    option.duration = $0.expectedTravelTime
                    option.points = UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { ($0.coordinate.latitude, $0.coordinate.longitude) }
                    return option
                } as [Plan.Option]
                path.options += options
                DispatchQueue.main.async { [weak self] in
                    self?.refresh()
                    if (transport == .automobile && self?._driving == true) || (transport == .walking && self?._walking == true) {
                        self?.addOverlays(options.map { Line(path, option: $0) }, level: .aboveLabels)
                    }
                }
            }
        }
    }
    
    private func filter() {
        removeOverlays(overlays.filter { $0 is Line })
        addOverlays(plan.path.flatMap { path in path.options.filter { ($0.mode == .walking && _walking) || ($0.mode == .driving && _driving) }.map { Line(path, option: $0) } }, level: .aboveLabels)
    }
}
