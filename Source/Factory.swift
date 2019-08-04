import MapKit

public final class Factory {
    struct Shot {
        var options = MKMapSnapshotter.Options()
        var tile = 0
        var x = 0
        var y = 0
    }
    
    public var error: ((Error) -> Void)?
    public var progress: ((Float) -> Void)?
    public var complete: ((String) -> Void)?
    public let plan: Plan
    var rect = MKMapRect()
    var range = [13, 16, 19]
    private(set) var content = Data()
    private(set) var info = Data()
    private(set) var shots = [Shot]()
    private(set) var chunks = 0
    private weak var shooter: MKMapSnapshotter?
    private var total = Float()
    private let group = DispatchGroup()
    private let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    private let margin = 0.001
    private let id = UUID().uuidString
    private let queue = DispatchQueue(label: "", qos: .userInteractive, target: .global(qos: .userInteractive))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    public init(_ plan: Plan) {
        self.plan = plan
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            self?.shooter?.cancel()
            self?.group.leave()
            DispatchQueue.main.async { [weak self] in self?.error?(Fail("Mapping timed out.")) }
        }
    }
    
    public func prepare() {
        var url = self.url
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try! url.setResourceValues(resources)
    }
    
    public func measure() {
        rect = {
            {
                let rect = {
                    .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $1.y - $0.y)
                } (MKMapPoint(.init(latitude: $0.first!.0 + margin, longitude: $1.first!.1 - margin)),
                   MKMapPoint(.init(latitude: $0.last!.0 - margin, longitude: $1.last!.1 + margin))) as MKMapRect
                return rect
            } ($0.sorted { $0.0 > $1.0 }, $0.sorted { $0.1 < $1.1 })
        } (plan.path.flatMap { $0.options.flatMap { $0.points } })
    }
    
    public func divide() {
        range.map { ($0, ceil(1 / (Double(1 << $0) / 1048575)) * 256) }.forEach { tile in
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
                    shot.options.size = .init(width: 1280, height: 1280)
                    shot.options.mapRect = .init(x: Double(x) * tile.1, y: Double(y) * tile.1, width: tile.1 * 5, height: tile.1 * 5)
                    shots.append(shot)
                }
            }
        }
        total = Float(shots.count)
    }
    
    public func shoot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let shot = self.shots.last else { return }
            
            self.group.enter()
            if self.shots.count == Int(self.total) {
                self.group.notify(queue: .global(qos: .background)) { [weak self] in self?.finish() }
            }
            
            self.progress?((self.total - Float(self.shots.count)) / self.total)
            self.timer.schedule(deadline: .now() + 15)
            let shooter = MKMapSnapshotter(options: shot.options)
            self.shooter = shooter
            shooter.start(with: self.queue) { [weak self] in
                self?.timer.schedule(deadline: .distantFuture)
                do {
                    if let error = $1 {
                        throw error
                    } else if let result = $0 {
                        self?.group.enter()
                        self?.queue.async { [weak self] in
                            self?.result(result, shot: shot)
                        }
                        self?.shots.removeLast()
                        self?.shoot()
                    } else {
                        throw Fail("Couldn't create map")
                    }
                } catch let error {
                    DispatchQueue.main.async { [weak self] in self?.error?(error) }
                }
                self?.group.leave()
            }
        }
    }
    
    func chunk(_ bits: Data, tile: Int, x: Int, y: Int) {
        withUnsafeBytes(of: UInt8(tile)) { info += $0 }
        withUnsafeBytes(of: UInt32(x)) { info += $0 }
        withUnsafeBytes(of: UInt32(y)) { info += $0 }
        withUnsafeBytes(of: UInt32(content.count)) { info += $0 }
        withUnsafeBytes(of: UInt32(bits.count)) { info += $0 }
        content += bits
        chunks += 1
    }
    
    func wrap() -> Data {
        withUnsafeBytes(of: UInt32(chunks)) { info.insert(contentsOf: $0, at: 0) }
        return Press().code(info + content)
    }
    
    private func result(_ result: MKMapSnapshotter.Snapshot, shot: Shot) {
        (0 ..< 5).forEach { x in
            (0 ..< 5).forEach { y in
                let image = NSImage(size: .init(width: 256, height: 256))
                image.lockFocus()
                result.image.draw(in: .init(x: 0, y: 0, width: 256, height: 256), from: .init(x: 256 * x, y: 256 * y, width: 256, height: 256), operation: .copy, fraction: 1)
                image.unlockFocus()
                chunk(NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])!, tile: shot.tile, x: shot.x + x, y: shot.y + 4 - y)
            }
        }
        group.leave()
    }
    
    private func finish() {
        try! wrap().write(to: url.appendingPathComponent(id + ".argonaut"), options: .atomic)
//        JSONEncoder().encode(plan)
        
        DispatchQueue.main.async { [weak self] in
            guard let id = self?.id else { return }
            self?.complete?(id)
        }
    }
    
    private func stride(_ tile: Double, start: Double, length: Double) -> StrideTo<Int> {
        return {
            Swift.stride(from: $0, to: $0 + $1, by: 5)
        } (Int(start / tile), Int(ceil(length / tile)))
    }
}
