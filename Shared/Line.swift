import Argo
import MapKit

final class Line: NSObject, MKOverlay {
    let point: [MKMapPoint]
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    
    init(_ path: [Path]) {
        point = path.flatMap { $0.options.filter { $0.mode == app.session.settings.mode }.flatMap { $0.points.map { .init(.init(latitude: $0.0, longitude: $0.1)) } } }
        if point.isEmpty {
            boundingMapRect = .null
        } else {
            boundingMapRect = {
                .init(x: $0.first!.x, y: $1.first!.y, width: $0.last!.x - $0.first!.x, height: $1.last!.y - $1.first!.y)
            } (point.sorted { $0.x < $1.x }, point.sorted { $0.y < $1.y })
        }
        coordinate = boundingMapRect.origin.coordinate
        super.init()
    }
}
