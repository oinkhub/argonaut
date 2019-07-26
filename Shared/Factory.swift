import MapKit

public final class Factory {
    public var plan = [Route]()
    public let id = UUID().uuidString
    private(set) var rect = MKMapRect()
    private let margin = 0.01
    
    public init() { }
    
    public func measure() {
        plan.flatMap({ $0.path.reduce(into: [CLLocationCoordinate2D]()) {
            var points = [CLLocationCoordinate2D](repeating: .init(), count: $1.polyline.pointCount)
            $1.polyline.getCoordinates(&points, range: .init(location: 0, length: $1.polyline.pointCount))
            $0.append(contentsOf: points) }}).forEach {
                rect.origin = MKMapPoint(.init(latitude: rect.minY == 0 || rect.minY < $0.latitude ? $0.latitude - margin: rect.minY, longitude: rect.minX == 0 || rect.minX < $0.longitude ? $0.longitude - margin: rect.minX))
        }
    }
}
