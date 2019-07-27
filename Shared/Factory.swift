import MapKit

public final class Factory {
    public var plan = [Route]()
    public let id = UUID().uuidString
    private(set) var rect = MKMapRect()
    private let margin = Double(7456.540482312441)
    
    public init() { }
    
    public func measure() {
        rect = {{{ .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $1.y - $0.y)} (MKMapPoint(.init(latitude: $0.first!.latitude, longitude: $1.first!.longitude)), MKMapPoint(.init(latitude: $0.last!.latitude, longitude: $1.last!.longitude)))} ($0.sorted(by: { $0.latitude < $1.latitude }), $0.sorted(by: { $0.longitude < $1.longitude }))} (plan.flatMap({ $0.path.flatMap({ UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { $0.coordinate }})}))
    }
}
