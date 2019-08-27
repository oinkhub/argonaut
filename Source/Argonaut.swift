import Foundation

public final class Argonaut {
    public static let tile = 512.0
    static let size = 100_000
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    static let temporal = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("map.argonaut")
    
    public static func load(_ id: String) -> (Plan, Cart) {
        let plan = Plan()
        let cart = Cart()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let input = InputStream(url: Coder.decode(url(id)))!
        input.open()
        input.read(buffer, maxLength: 1)
        (0 ..< buffer.pointee).forEach { _ in
            let item = Plan.Path()
            input.read(buffer, maxLength: 1)
            let len = Int(buffer.pointee)
            input.read(buffer, maxLength: len)
            item.name = String(cString: buffer)
            input.read(buffer, maxLength: 8)
            item.latitude = buffer.withMemoryRebound(to: Double.self, capacity: 1) { $0[0] }
            input.read(buffer, maxLength: 8)
            item.longitude = buffer.withMemoryRebound(to: Double.self, capacity: 1) { $0[0] }
            input.read(buffer, maxLength: 1)
            (0 ..< buffer.pointee).forEach { _ in
                let option = Plan.Option()
                input.read(buffer, maxLength: 1)
                option.mode = Plan.Mode(rawValue: buffer.pointee)!
                input.read(buffer, maxLength: 8)
                option.duration = buffer.withMemoryRebound(to: Double.self, capacity: 1) { $0[0] }
                input.read(buffer, maxLength: 8)
                option.distance = buffer.withMemoryRebound(to: Double.self, capacity: 1) { $0[0] }
                input.read(buffer, maxLength: 2)
                (0 ..< Int(buffer.withMemoryRebound(to: UInt16.self, capacity: 1) { $0[0] })).forEach { _ in
                    input.read(buffer, maxLength: 16)
                    option.points.append(buffer.withMemoryRebound(to: Double.self, capacity: 2) { ($0[0], $0[1]) })
                }
                item.options.append(option)
            }
            plan.path.append(item)
        }
        input.read(buffer, maxLength: 4)
        cart.map = (0 ..< Int(buffer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0[0] })).reduce(into: [:]) { map, _ in
            input.read(buffer, maxLength: 1)
            let tile = buffer.pointee
            input.read(buffer, maxLength: 4)
            let x = buffer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0[0] }
            input.read(buffer, maxLength: 4)
            let y = buffer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0[0] }
            input.read(buffer, maxLength: 4)
            let length = Int(buffer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0[0] })
            input.read(buffer, maxLength: length)
            map["\(tile)-\(x).\(y)"] = Data(bytes: buffer, count: length)
        }
        buffer.deallocate()
        input.close()
        return (plan, cart)
    }
    
    public static func delete(_ id: String) {
        DispatchQueue.global(qos: .background).async {
            try? FileManager.default.removeItem(at: url(id))
        }
    }
    
    public static func share(_ item: Session.Item, result: @escaping((URL) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            let out = OutputStream(url: temporal, append: false)!
            out.open()
            let coded = Coder.code(try! JSONEncoder().encode(item))
            _ = withUnsafeBytes(of: UInt16(coded.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 2) }
            _ = coded.withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: coded.count) }
            let input = InputStream(url: url(item.id))!
            input.open()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
            while input.hasBytesAvailable {
                out.write(buffer, maxLength: input.read(buffer, maxLength: size))
            }
            buffer.deallocate()
            input.close()
            out.close()
            DispatchQueue.main.async {
                result(temporal)
            }
        }
    }
    
    public static func receive(_ map: URL, result: @escaping((Session.Item) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            guard map.pathExtension == "argonaut" else { return }
            prepare()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
            let input = InputStream(url: map)!
            input.open()
            input.read(buffer, maxLength: 2)
            let item = try! JSONDecoder().decode(Session.Item.self, from: Coder.decode(.init(bytes: buffer, count: input.read(buffer, maxLength: Int(buffer.withMemoryRebound(to: UInt16.self, capacity: 1) { $0.pointee })))))
            let out = OutputStream(url: url(item.id), append: false)!
            out.open()
            while input.hasBytesAvailable {
                out.write(buffer, maxLength: input.read(buffer, maxLength: size))
            }
            buffer.deallocate()
            input.close()
            out.close()
            DispatchQueue.main.async {
                result(item)
            }
        }
    }
    
    static func save(_ factory: Factory) {
        prepare()
        let out = OutputStream(url: temporal, append: false)!
        out.open()
        _ = factory.plan.code().withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: $0.count) }
        _ = withUnsafeBytes(of: UInt32(factory.chunks)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 4) }
        _ = factory.content.withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: $0.count) }
        out.close()
        Coder.code(temporal, to: url(factory.item.id))
        try! FileManager.default.removeItem(at: temporal)
    }
    
    private static func prepare() {
        var url = self.url
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try! url.setResourceValues(resources)
    }
    
    private static func url(_ id: String) -> URL { return url.appendingPathComponent(id + ".argonaut") }
}
