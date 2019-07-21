import MapKit

final class Route {
    var path = [MKRoute]()
    let mark: Mark
    
    init(_ mark: CLLocationCoordinate2D) {
        self.mark = Mark()
        self.mark.coordinate = mark
    }
}
