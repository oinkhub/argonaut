import MapKit

public final class Route {
    public var path = [MKRoute]()
    public let mark: Mark
    
    public init(_ mark: CLLocationCoordinate2D) {
        self.mark = Mark()
        self.mark.coordinate = mark
    }
}
