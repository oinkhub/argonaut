import MapKit

public final class Factory {
    struct Shot {
        var options = MKMapSnapshotter.Options()
        var tile = 0
        var x = 0
        var y = 0
    }
    
    public var error: ((Error) -> Void)!
    public var progress: ((Float) -> Void)!
    public var complete: ((Session.Item) -> Void)!
    public var plan = Plan()
    public var rect = MKMapRect()
    var range = (12 ... 19)
    private(set) var item = Session.Item()
    private(set) var content = Data()
    private(set) var info = Data()
    private(set) var shots = [Shot]()
    private(set) var chunks = 0
    let id = UUID().uuidString
    private weak var shooter: MKMapSnapshotter?
    private var total = Float()
    private let margin = 0.002
    private let queue = DispatchQueue(label: "", qos: .userInteractive, target: .global(qos: .userInteractive))
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    public init() {
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            self?.shooter?.cancel()
            DispatchQueue.main.async { [weak self] in self?.error(Fail("Mapping timed out.")) }
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
        } (plan.path.flatMap { $0.options.flatMap { $0.points } })
    }
    
    public func divide() {
        range.forEach { tile in
            let proportion = MKMapRect.world.width / pow(2, Double(tile))
            (Int(rect.minX / proportion) ..< Int(ceil(rect.maxX / proportion))).forEach { x in
                (Int(rect.minY / proportion) ..< Int(ceil(rect.maxY / proportion))).forEach { y in
                    var shot = Shot()
                    shot.tile = tile
                    shot.x = x
                    shot.y = y
                    if #available(OSX 10.14, *) {
                        shot.options.appearance = NSAppearance(named: .darkAqua)
                    }
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
        item.origin = plan.path.first?.name ?? ""
        item.destination = plan.path.last?.name ?? ""
        plan.path.forEach {
            $0.options.forEach {
                if $0.mode == .walking {
                    item.walking.duration += $0.duration
                    item.walking.distance += $0.distance
                } else {
                    item.driving.duration += $0.duration
                    item.driving.distance += $0.distance
                }
            }
        }
    }
    
    public func shoot() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let shot = self.shots.last else { return }
            self.progress((self.total - Float(self.shots.count)) / self.total)
            self.timer.schedule(deadline: .now() + 9)
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
                        self.chunk(NSBitmapImageRep(cgImage: result.image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])!, tile: shot.tile, x: shot.x, y: shot.y)
                        if self.shots.isEmpty {
                            Argonaut.save(self.id, data: self.wrap())
                            DispatchQueue.main.async { [weak self] in
                                guard let item = self?.item else { return }
                                self?.complete(item)
                            }
                        }
                    } else {
                        throw Fail("Couldn't create map")
                    }
                } catch let error {
                    DispatchQueue.main.async { [weak self] in self?.error?(error) }
                }
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
    
    func wrap() -> Data { return plan.code() + withUnsafeBytes(of: UInt32(chunks)) { Data($0) } + info + content }
}
