import MapKit

public final class Factory {
    struct Shot {
        var options = MKMapSnapshotter.Options()
        var tile = 0
        var x = 0
        var y = 0
    }
    
    public var plan = [Route]()
    public var error: ((Error) -> Void)?
    public var progress: ((Float) -> Void)?
    public var complete: ((String) -> Void)?
    var rect = MKMapRect()
//    var range = (13 ... 20)
    var range = [14, 17, 20]
    private(set) var shots = [Shot]()
    private weak var shooter: MKMapSnapshotter?
    private var total = Float()
    private let margin = 0.002
    private let id = UUID().uuidString
    private let queue = DispatchQueue(label: "", qos: .default, target: .global(qos: .default))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    public init() {
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            self?.shooter?.cancel()
            DispatchQueue.main.async { [weak self] in self?.error?(Fail("Mapping timed out.")) }
        }
    }
    
    public func prepare() {
        print(URL(fileURLWithPath: NSTemporaryDirectory() + id))
        try! FileManager.default.createDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory() + id), withIntermediateDirectories: true)
    }
    
    public func measure() {
        rect = {{
            let rect = { .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $1.y - $0.y) } (MKMapPoint(.init(latitude: $0.first!.latitude + margin, longitude: $1.first!.longitude - margin)), MKMapPoint(.init(latitude: $0.last!.latitude - margin, longitude: $1.last!.longitude + margin))) as MKMapRect
            return rect
        } ($0.sorted(by: { $0.latitude > $1.latitude }), $0.sorted(by: { $0.longitude < $1.longitude }))} (plan.flatMap({ $0.path.flatMap({ UnsafeBufferPointer(start: $0.polyline.points(), count: $0.polyline.pointCount).map { $0.coordinate }})}))
    }
    
    public func divide() {
        range.map({ ($0, ceil(1 / (Double(1 << $0) / 1048575)) * 256) }).forEach { tile in
            stride(tile.1, start: rect.minX, length: rect.width).forEach { x in
                stride(tile.1, start: rect.minY, length: rect.height).forEach { y in
                    var shot = Shot()
                    shot.tile = Int(tile.0)
                    shot.x = x
                    shot.y = y
                    if #available(OSX 10.14, *) {
                        shot.options.appearance = NSAppearance(named: .darkAqua)
                    }
                    shot.options.mapType = .standard
                    shot.options.size = .init(width: 2560, height: 2560)
                    shot.options.mapRect = .init(x: Double(x) * tile.1, y: Double(y) * tile.1, width: tile.1 * 10, height: tile.1 * 10)
                    shots.append(shot)
                }
            }
        }
        total = Float(shots.count)
    }
    
    public func shoot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let shot = self.shots.last
            else {
                self.complete?(self.id)
                return
            }
            self.progress?((self.total - Float(self.shots.count)) / self.total)
            self.timer.schedule(deadline: .now() + 30)
            let shooter = MKMapSnapshotter(options: shot.options)
            self.shooter = shooter
            let active = NSApp.isActive
            print(active)
            shooter.start(with: active ? self.queue : .main) { [weak self] in
                self?.timer.schedule(deadline: .distantFuture)
                do {
                    if let error = $1 {
                        throw error
                    } else if let result = $0 {
                        if active {
                            self?.queue.async { [weak self] in
                                self?.result(result, shot: shot)
                            }
                        } else {
                            DispatchQueue.main.async { [weak self] in
                                self?.result(result, shot: shot)
                            }
                        }
                        self?.shots.removeLast()
                        self?.shoot()
                    } else {
                        throw Fail("Couldn't create map")
                    }
                } catch let error {
                    DispatchQueue.main.async { [weak self] in self?.error?(error) }
                }
            }
        }
    }
    
    private func result(_ result: MKMapSnapshotter.Snapshot, shot: Shot) {
        (0 ..< 10).forEach { x in
            (0 ..< 10).forEach { y in
                let image = NSImage(size: .init(width: 256, height: 256))
                image.lockFocus()
                result.image.draw(in: .init(x: 0, y: 0, width: 256, height: 256), from: .init(x: 256 * x, y: 256 * y, width: 256, height: 256), operation: .copy, fraction: 1)
                image.unlockFocus()
                try! NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])!.write(to: .init(fileURLWithPath: NSTemporaryDirectory() + id + "/\(shot.tile)-\(shot.x + x).\(shot.y + 9 - y).png"))
            }
        }
    }
    
    private func stride(_ tile: Double, start: Double, length: Double) -> StrideTo<Int> {
        return {
            Swift.stride(from: $0, to: $0 + $1, by: 10)
        } (Int(start / tile), Int(ceil(length / tile)))
    }
}
