import Foundation

public final class Argonaut {
    public static let tile = 512.0
    static let size = 100_000
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    static let temporal = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("map.argonaut")
    
    public static func load(_ id: String) -> (Plan, Cart) {
        let plan = Plan()
        let cart = Cart(url(id))
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let input = InputStream(url: url(id))!
        input.open()
        input.read(buffer, maxLength: 1)
        (0 ..< buffer.pointee).forEach { _ in
            let item = Plan.Path()
            input.read(buffer, maxLength: 1)
            let length = Int(buffer.pointee)
            input.read(buffer, maxLength: length)
            item.name = String(decoding: Data(bytes: buffer, count: length), as: UTF8.self)
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
        while input.hasBytesAvailable && input.read(buffer, maxLength: 1) == 1 {
            let tile = buffer.pointee
            input.read(buffer, maxLength: 4)
            let x = buffer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0[0] }
            input.read(buffer, maxLength: 4)
            let y = buffer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0[0] }
            input.read(buffer, maxLength: 4)
            let length = Int(buffer.withMemoryRebound(to: UInt32.self, capacity: 1) { $0[0] })
            let index = (input.property(forKey: .fileCurrentOffsetKey) as! NSNumber).intValue
            input.setProperty(NSNumber(value: index + length), forKey: .fileCurrentOffsetKey)
            cart.map["\(tile)-\(x).\(y)"] = (index, length)
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
            let coded = try! JSONEncoder().encode(item)
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
            let item = try! JSONDecoder().decode(Session.Item.self, from: .init(bytes: buffer, count: input.read(buffer, maxLength: Int(buffer.withMemoryRebound(to: UInt16.self, capacity: 1) { $0.pointee }))))
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
        let out = OutputStream(url: url(factory.item.id), append: false)!
        out.open()
        _ = withUnsafeBytes(of: UInt8(factory.plan.path.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
        factory.plan.path.forEach {
            let name = Data($0.name.utf8)
            _ = withUnsafeBytes(of: UInt8(name.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
            _ = name.withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: name.count) }
            _ = withUnsafeBytes(of: $0.latitude) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 8) }
            _ = withUnsafeBytes(of: $0.longitude) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 8) }
            _ = withUnsafeBytes(of: UInt8($0.options.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
            $0.options.forEach {
                _ = withUnsafeBytes(of: UInt8($0.mode.rawValue)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
                _ = withUnsafeBytes(of: $0.duration) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 8) }
                _ = withUnsafeBytes(of: $0.distance) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 8) }
                _ = withUnsafeBytes(of: UInt16($0.points.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 2) }
                $0.points.forEach {
                    _ = withUnsafeBytes(of: $0.0) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 8) }
                    _ = withUnsafeBytes(of: $0.1) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 8) }
                }
            }
        }
        let input = InputStream(url: temporal)!
        input.open()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        while input.hasBytesAvailable {
            out.write(buffer, maxLength: input.read(buffer, maxLength: size))
        }
        buffer.deallocate()
        input.close()
        out.close()
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
