import MapKit

public final class Factory {
    public var plan = [Route]()
    public let id = UUID().uuidString
    var rect = MKMapRect()
    var shots = [MKMapSnapshotter.Options]()
    private let margin = 0.01
    
    public init() { }
    
    public func measure() {
        rect = {{
            let rect = { .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $1.y - $0.y)} (MKMapPoint(.init(latitude: $0.first!.latitude - margin, longitude: $1.first!.longitude - margin)), MKMapPoint(.init(latitude: $0.last!.latitude + margin, longitude: $1.last!.longitude + margin))) as MKMapRect
            return rect
        } ($0.sorted(by: { $0.latitude < $1.latitude }), $0.sorted(by: { $0.longitude < $1.longitude }))} (plan.flatMap({ $0.path.flatMap({ UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { $0.coordinate }})}))
    }
    
    public func divide() {
        (0 ... 21).map({ ceil(1 / (Double(1 << $0) / 1048575)) * 512 }).forEach { tile in
//            {
//
//            } (Int(rect.minX / tile), Int(rect.minY / tile), Int(ceil(rect.width / tile)), Int(ceil(rect.height / tile)))
            
            
            
            for x in stride(from: Int(rect.minX / tile), to: Int(ceil(rect.width / tile)), by: 10) {
                for y in stride(from: Int(rect.minY / tile), to: Int(ceil(rect.height / tile)), by: 10) {
                    shots.append({
                        $0.size = .init(width: 5120, height: 5120)
                        $0.mapRect = .init(x: Double(x) * tile, y: Double(y) * tile, width: tile * 10, height: tile * 10)
                        return $0
                    } (MKMapSnapshotter.Options()))
                }
            }
        }
    }
    /*
     
     var start = Int(start / tile)
     let size = Int(ceil(size / tile))
     let delta = (10 - size) / 2
     if delta > 0 {
     start = max(0, start - delta)
     }
     return stride(from:start, to:start + size, by:10)
     */
}
