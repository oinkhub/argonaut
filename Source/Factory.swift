import MapKit

public final class Factory {
    public var plan = [Route]()
    public var error: ((Error) -> Void)?
    public let id = UUID().uuidString
    var rect = MKMapRect()
    var shots = [MKMapSnapshotter.Options]()
    var range = (0 ... 21)
    private var shooter: MKMapSnapshotter?
    private let margin = 0.01
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    public init() {
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            
        }
    }
    
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
            ({
                stride(from: $0, to: $0 + w, by: 10)
            } (max(0, Int(rect.minX / tile) - max(0, ((10 - w) / 2))))).forEach { x in
                ({
                    stride(from: $0, to: $0 + h, by: 10)
                } (max(0, Int(rect.minY / tile) - max(0, ((10 - h) / 2))))).forEach { y in
                    shots.append({
                        $0.size = .init(width: 5120, height: 5120)
                        $0.mapRect = .init(x: Double(x) * tile, y: Double(y) * tile, width: tile * 10, height: tile * 10)
                        return $0
                    } (MKMapSnapshotter.Options()))
                }
            }
        }
    }
    
    public func shoot() {
        queue.async { [weak self] in
            guard let self = self, let shot = self.shots.last else { return }
            self.timer.schedule(deadline: .now() + 6)
            self.shooter = MKMapSnapshotter(options: shot)
            self.shooter!.start(with: self.queue) { [weak self] in
                self?.timer.schedule(deadline: .distantFuture)
                do {
                    if let error = $1 {
                        throw error
                    } else if let image = $0?.image {
                        let url = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString)
                        try! NSBitmapImageRep(data: image.tiffRepresentation!)!.representation(using: .png, properties: [:])!.write(to: url)
                        print(url)
                    } else {
                        throw Fail("Couldn't create map")
                    }
                } catch let error {
                    DispatchQueue.main.async { [weak self] in self?.error?(error) }
                }
            }
        }
    }
}
