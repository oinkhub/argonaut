import MapKit

final class Route {
    weak var to: Mark?
    var drive = [MKRoute]()
    var walk = [MKRoute]()
    let from: Mark
    
    init(_ from: CLLocationCoordinate2D) {
        self.from = Mark()
        self.from.coordinate = from
    }
}
