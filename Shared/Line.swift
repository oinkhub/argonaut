import Argonaut
import MapKit

final class Line: NSObject, MKOverlay {
    private(set) weak var path: Path!
    private(set) weak var option: Path.Option!
    let point: [MKMapPoint]
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    
    init(_ path: Path, option: Path.Option) {
        self.path = path
        self.option = option
        point = option.points.map { .init(.init(latitude: $0.0, longitude: $0.1)) }
        boundingMapRect = {
            .init(x: $0.first!.x, y: $1.first!.y, width: $0.last!.x - $0.first!.x, height: $1.last!.y - $1.first!.y)
        } (point.sorted { $0.x < $1.x }, point.sorted { $0.y < $1.y })
        coordinate = .init(latitude: path.latitude, longitude: path.longitude)
        super.init()
    }
}
