import MapKit

public final class Factory {
    public var plan = [Route]()
    public let id = UUID().uuidString
    var rect = MKMapRect()
    var shots = [MKMapSnapshotter.Options]()
    var range = (0 ... 21)
    private let margin = 0.01
    
    public init() { }
    
    public func measure() {
        rect = {{
            let rect = { .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $1.y - $0.y)} (MKMapPoint(.init(latitude: $0.first!.latitude - margin, longitude: $1.first!.longitude - margin)), MKMapPoint(.init(latitude: $0.last!.latitude + margin, longitude: $1.last!.longitude + margin))) as MKMapRect
            return rect
        } ($0.sorted(by: { $0.latitude < $1.latitude }), $0.sorted(by: { $0.longitude < $1.longitude }))} (plan.flatMap({ $0.path.flatMap({ UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { $0.coordinate }})}))
    }
    
    public func divide() {
        range.map({ ceil(1 / (Double(1 << $0) / 1048575)) * 512 }).forEach { tile in
            let w = Int(ceil(rect.width / tile))
            let h = Int(ceil(rect.height / tile))
            let x = max(0, Int(rect.minX / tile) - max(0, ((10 - w) / 2)))
            let y = max(0, Int(rect.minY / tile) - max(0, ((10 - h) / 2)))
            stride(from: x, to: x + w, by: 10).forEach { x in
                stride(from: y, to: y + h, by: 10).forEach { y in
                    shots.append({
                        $0.size = .init(width: 5120, height: 5120)
                        $0.mapRect = .init(x: Double(x) * tile, y: Double(y) * tile, width: tile * 10, height: tile * 10)
                        return $0
                    } (MKMapSnapshotter.Options()))
                }
            }
            
        }
    }
}
