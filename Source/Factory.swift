import MapKit
import Compression

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
    var range = [13, 16, 19]
    private(set) var shots = [Shot]()
    private(set) var chunks = 0
    private weak var shooter: MKMapSnapshotter?
    private var total = Float()
    private var data = Data()
    private let group = DispatchGroup()
    private let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    private let margin = 0.001
    private let id = UUID().uuidString
    private let queue = DispatchQueue(label: "", qos: .userInteractive, target: .global(qos: .userInteractive))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    public init() {
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
        chunks += 1
    }
    
    func wrap() {
        
    }
    
    private func result(_ result: MKMapSnapshotter.Snapshot, shot: Shot) {
        (0 ..< 5).forEach { x in
            (0 ..< 5).forEach { y in
                let image = NSImage(size: .init(width: 256, height: 256))
                image.lockFocus()
                result.image.draw(in: .init(x: 0, y: 0, width: 256, height: 256), from: .init(x: 256 * x, y: 256 * y, width: 256, height: 256), operation: .copy, fraction: 1)
                image.unlockFocus()
                let chunk = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])!
                var info = Data()
                withUnsafeBytes(of: UInt8(shot.tile)) { info.append(contentsOf: $0.reversed()) }
                withUnsafeBytes(of: UInt32(shot.x + x)) { info.append(contentsOf: $0.reversed()) }
                withUnsafeBytes(of: UInt32(shot.y + 4 - y)) { info.append(contentsOf: $0.reversed()) }
                withUnsafeBytes(of: UInt32(data.count)) { info.append(contentsOf: $0.reversed()) }
                withUnsafeBytes(of: UInt32(chunk.count)) { info.append(contentsOf: $0.reversed()) }
                data += chunk
                data.insert(contentsOf: info, at: 0)
            }
        }
        group.leave()
    }
    
    private func finish() {
        withUnsafeBytes(of: UInt32(chunks)) { data.insert(contentsOf: $0.reversed(), at: 0) }
        try! pressed().write(to: url.appendingPathComponent(id + ".argonaut"), options: .atomic)
//        JSONEncoder().encode(plan)
        
        DispatchQueue.main.async { [weak self] in
            guard let id = self?.id else { return }
            self?.complete?(id)
        }
    }
    
    private func pressed() -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let wrote = compression_encode_buffer(buffer, data.count * 10, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                  data.count, nil, COMPRESSION_ZLIB)
            let result = Data(bytes: buffer, count: wrote)
            buffer.deallocate()
            return result
        }
    }
    
    private func stride(_ tile: Double, start: Double, length: Double) -> StrideTo<Int> {
        return {
            Swift.stride(from: $0, to: $0 + $1, by: 5)
        } (Int(start / tile), Int(ceil(length / tile)))
    }
}
