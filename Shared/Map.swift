import Argonaut
import MapKit

final class Map: MKMapView, MKMapViewDelegate {
    var refresh: (() -> Void)!
    var user: ((CLLocation) -> Void)?
    var zoom: ((CGFloat) -> Void)?
    var drag = true
    private(set) var path = [Path]()
    private var tiler: Tiler!
    private var first = true
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
        region.center = userLocation.location == nil ? centerCoordinate : userLocation.coordinate
        region.span = span()
        setRegion(region, animated: false)
    }
    
    func mapView(_: MKMapView, didUpdate: MKUserLocation) {
        guard let location = didUpdate.location else { return }
        if first || app.session.settings.follow {
            setCenter(location.coordinate, animated: first ? false : true)
        }
        user?(location)
        first = false
    }
    
    func mapView(_: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView?
        switch viewFor {
        case is MKUserLocation:
            view = dequeueReusableAnnotationView(withIdentifier: "User") as? User ?? User()
        case is Mark:
            view = dequeueReusableAnnotationView(withIdentifier: "Marker") as? Marker ?? Marker(drag)
            (view as! Marker).index = "\(path.firstIndex { $0 === (viewFor as! Mark).path }! + 1)"
        default: break
        }
        view?.annotation = viewFor
        return view
    }
    
    func mapView(_: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState) {
        if didChange == .ending {
            if let mark = annotationView.annotation as? Mark {
                locate(mark)
                direct(mark)
            }
        }
    }
    
    func mapView(_: MKMapView, rendererFor: MKOverlay) -> MKOverlayRenderer {
        if let line = rendererFor as? Line {
            return Liner(line)
        } else {
            return MKTileOverlayRenderer(tileOverlay: rendererFor as! Tiler)
        }
    }
    
    func mapView(_: MKMapView, regionDidChangeAnimated: Bool) {
        zoom?(.init(round(log2(360 * Double(frame.width) / Argonaut.tile / region.span.longitudeDelta))))
    }
    
    func mapView(_: MKMapView, didDeselect: MKAnnotationView) { didDeselect.isSelected = false }
    func mapView(_: MKMapView, didSelect: MKAnnotationView) {
        didSelect.isSelected = true
        if let coordinate = didSelect.annotation?.coordinate {
            setCenter(coordinate, animated: true)
        }
    }
    
    func add(_ coordinate: CLLocationCoordinate2D) -> Mark {
        let item = Path()
        item.latitude = coordinate.latitude
        item.longitude = coordinate.longitude
        path.append(item)
        let mark = Mark(item)
        addAnnotation(mark)
        selectAnnotation(mark, animated: true)
        direct(mark)
        return mark
    }
    
    func remove(_ path: Path) {
        selectedAnnotations.forEach { deselectAnnotation($0, animated: true) }
        removeAnnotations(annotations.filter { ($0 as? Mark)?.path === path })
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let index = self.path.firstIndex(where: { $0 === path }) else { return }
            self.removeOverlays(self.overlays.filter { ($0 as? Line)?.path === path } )
            if index > 0 {
                if index < self.path.count - 1 {
                    self.direction(self.path[index - 1], destination: self.path[index + 1])
                } else {
                    self.removeOverlays(self.overlays.filter { ($0 as? Line)?.path === self.path[index - 1] } )
                    self.path[index - 1].options = []
                }
            }
            self.path.remove(at: index)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.refresh()
                self.annotations.compactMap { $0 as? Mark }.compactMap { self.view(for: $0) as? Marker }.forEach { marker in
                    if let index = self.path.firstIndex(where: { $0 === (marker.annotation as? Mark)?.path }) {
                        marker.index = "\(index + 1)"
                    }
                }
            }
        }
    }
    
    func tile(_ project: ([Path], Cart)) {
        tiler = Tiler(project.1)
        retile()
        self.path = project.0
        addAnnotations(path.map { Mark($0) })
        filter()
    }
    
    func retile() {
        removeOverlay(tiler)
        if app.session.settings.map != .apple {
            tiler.canReplaceMapContent = app.session.settings.map == .argonaut
            addOverlay(tiler, level: .aboveLabels)
        }
    }
    
    func remark() {
        annotations.filter { $0 is Mark }.forEach { view(for: $0)?.isHidden = !app.session.settings.pins }
    }
    
    func filter() {
        removeOverlays(overlays.filter { $0 is Line })
        if app.session.settings.directions {
            addOverlays(path.flatMap { path in path.options.filter { $0.mode == app.session.settings.mode }
            .map { Line(path, option: $0) } }, level: .aboveLabels)
        }
    }
    
    func rezoom() {
        var region = self.region
        region.span = span()
        setRegion(region, animated: true)
    }
    
    @objc func pin() { locate(add(centerCoordinate)) }
    
    @objc func me() {
        if annotations.contains(where: { $0 === userLocation }) {
            setCenter(userLocation.coordinate, animated: true)
        }
    }
    
    private func locate(_ mark: Mark) {
        geocoder.reverseGeocodeLocation(.init(latitude: mark.path.latitude, longitude: mark.path.longitude)) { [weak self, weak mark] in
            if $1 == nil, let mark = mark {
                mark.path.name = $0?.first?.name ?? ""
                (self?.view(for: mark) as? Marker)?.refresh()
                self?.refresh()
            }
        }
    }
    
    private func direct(_ mark: Mark) {
        if let index = path.firstIndex(where: { $0 === mark.path }) {
            if index > 0 {
                direction(path[index - 1], destination: mark.path)
            }
            if index < path.count - 1 {
                direction(path[index], destination: path[index + 1])
            }
        }
    }
    
    private func direction(_ path: Path, destination: Path) {
        removeOverlays(overlays.filter { ($0 as? Line)?.path === path })
        path.options = []
        direction(.walking, path: path, destination: destination)
        direction(.driving, path: path, destination: destination)
        fly(path, destination: destination)
    }
    
    private func direction(_ mode: Session.Mode, path: Path, destination: Path) {
        let request = MKDirections.Request()
        request.transportType = mode == .driving ? .automobile : .walking
        request.source = .init(placemark: .init(coordinate: .init(latitude: path.latitude, longitude: path.longitude), addressDictionary: nil))
        request.destination = .init(placemark: .init(coordinate: .init(latitude: destination.latitude, longitude: destination.longitude), addressDictionary: nil))
        MKDirections(request: request).calculate { [weak self] in
            if $1 == nil, let paths = $0?.routes {
                let options = paths.map {
                    let option = Path.Option()
                    option.mode = mode
                    option.distance = $0.distance
                    option.duration = $0.expectedTravelTime
                    option.points = UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { ($0.coordinate.latitude, $0.coordinate.longitude) }
                    return option
                } as [Path.Option]
                path.options += options
                self?.filter(mode)
            }
        }
    }
    
    private func fly(_ path: Path, destination: Path) {
        let option = Path.Option()
        option.mode = .flying
        option.distance = CLLocation(latitude: path.latitude, longitude: path.longitude).distance(from: .init(latitude: destination.latitude, longitude: destination.longitude))
        option.points = [(path.latitude, path.longitude), (destination.latitude, destination.longitude)]
        path.options.append(option)
        filter(.flying)
    }
    
    private func filter(_ mode: Session.Mode) {
        DispatchQueue.main.async { [weak self] in
            if app.session.settings.mode == mode {
                self?.refresh()
                self?.filter()
            }
        }
    }
    
    private func span() -> MKCoordinateSpan {
        .init(latitudeDelta: app.session.settings.mode == .flying ? 20 : 0.005, longitudeDelta: app.session.settings.mode == .flying ? 20 : 0.005)
    }
}
