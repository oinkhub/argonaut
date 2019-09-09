import MapKit

public final class Factory {
    struct Shot {
        var options = MKMapSnapshotter.Options()
        var x = 0
        var y = 0
    }
    
    public var error: ((Error) -> Void)!
    public var progress: ((Float) -> Void)!
    public var complete: ((Session.Item) -> Void)!
    public var path = [Path]()
    public var rect = MKMapRect()
    public var mode = Session.Mode.walking
    var range = (0 ... 0)
    private(set) var item = Session.Item()
    private(set) var shots = [Shot]()
    let id = UUID().uuidString
    private weak var shooter: MKMapSnapshotter?
    private var total = Float()
    private let margin = 0.004
    private let queue = DispatchQueue(label: "", qos: .userInteractive, target: .global(qos: .userInteractive))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    private let out = OutputStream(url: Argonaut.temporal, append: false)!
    
    public init() {
        out.open()
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            self?.shooter?.cancel()
            DispatchQueue.main.async { [weak self] in self?.error(Fail("Mapping timed out.")) }
        }
    }
    
    deinit { out.close() }
    
    public func filter() {
        path.forEach { $0.options.removeAll { $0.mode != mode } }
        if mode == .flying {
            range = (2 ... 9)
        } else {
            range = (9 ... 18)
        }
    }
    
    public func measure() {
        rect = {
            {
                if $0.isEmpty { return rect }
                let rect = {
                    .init(x: $0.x, y: $0.y, width: $1.x - $0.x, height: $1.y - $0.y)
                } (MKMapPoint(.init(latitude: $0.first!.0 + margin, longitude: $1.first!.1 - margin)),
                   MKMapPoint(.init(latitude: $0.last!.0 - margin, longitude: $1.last!.1 + margin))) as MKMapRect
                return rect
            } ($0.sorted { $0.0 > $1.0 }, $0.sorted { $0.1 < $1.1 })
        } (path.flatMap { $0.options.flatMap { $0.points } })
    }
    
    public func divide() {
        range.forEach {
            let proportion = MKMapRect.world.width / pow(2, Double($0))
            (Int(rect.minX / proportion) ..< Int(ceil(rect.maxX / proportion))).forEach { x in
                (Int(rect.minY / proportion) ..< Int(ceil(rect.maxY / proportion))).forEach { y in
                    var shot = Shot()
                    shot.x = x
                    shot.y = y
                    shot.options.dark()
                    shot.options.mapType = .standard
                    shot.options.size = .init(width: Argonaut.tile, height: Argonaut.tile)
                    shot.options.mapRect = .init(x: Double(x) * proportion, y: Double(y) * proportion, width: proportion, height: proportion)
                    shots.append(shot)
                }
            }
        }
        total = Float(shots.count)
    }
    
    public func register() {
        item.id = id
        item.mode = mode
        item.origin = path.first?.name ?? ""
        item.destination = path.last?.name ?? ""
        path.forEach {
            $0.options.forEach {
                item.duration += $0.duration
                item.distance += $0.distance
            }
        }
    }
    
    public func shoot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let shot = self.shots.last else { return }
            self.progress((self.total - Float(self.shots.count)) / self.total)
            self.timer.schedule(deadline: .now() + 15)
            let shooter = MKMapSnapshotter(options: shot.options)
            self.shooter = shooter
            shooter.start(with: self.queue) { [weak self] in
                guard let self = self else { return }
                self.timer.schedule(deadline: .distantFuture)
                do {
                    if let error = $1 {
                        throw error
                    } else if let result = $0 {
                        self.shots.removeLast()
                        self.shoot()
                        self.chunk(result.data, x: shot.x, y: shot.y)
                        if self.shots.isEmpty {
                            self.out.close()
                            Argonaut.save(self)
                            DispatchQueue.main.async { [weak self] in
                                guard let item = self?.item else { return }
                                self?.complete(item)
                            }
                        }
                    } else {
                        throw Fail("Couldn't create map")
                    }
                } catch let error {
                    DispatchQueue.main.async { [weak self] in self?.error(error) }
                }
            }
        }
    }
    
    func chunk(_ bits: Data, x: Int, y: Int) {
        let chunk = Argonaut.code(bits)
        _ = [UInt32(x), UInt32(y), UInt32(chunk.count)].withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 12) }
        _ = chunk.withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: $0.count) }
    }
}
