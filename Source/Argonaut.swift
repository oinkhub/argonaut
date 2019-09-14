import Foundation
import Compression

public final class Argonaut {
    public static let tile = 512.0
    static let size = 100_000
    static let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static let url = root.appendingPathComponent("maps")
    static let temporal = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("map.argonaut")
    
    public class func load(_ id: String) -> ([Path], Cart) {
        var path = [Path]()
        let cart = Cart(url(id))
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let input = InputStream(url: url(id))!
        input.open()
        input.read(buffer, maxLength: 3)
        cart.zoom = (Int(buffer.pointee) ... Int(buffer.advanced(by: 1).pointee))
        (0 ..< buffer.advanced(by: 2).pointee).forEach { _ in
            let item = Path()
            input.read(buffer, maxLength: 1)
            let length = Int(buffer.pointee)
            if length > 0 {
                input.read(buffer, maxLength: length)
                item.name = String(decoding: Data(bytes: buffer, count: length), as: UTF8.self)
            }
            input.read(buffer, maxLength: 16)
            buffer.withMemoryRebound(to: Double.self, capacity: 2) {
                item.latitude = $0[0]
                item.longitude = $0[1]
            }
            input.read(buffer, maxLength: 1)
            (0 ..< buffer.pointee).forEach { _ in
                let option = Path.Option()
                input.read(buffer, maxLength: 1)
                option.mode = Session.Mode(rawValue: buffer.pointee)!
                input.read(buffer, maxLength: 16)
                buffer.withMemoryRebound(to: Double.self, capacity: 2) {
                    option.duration = $0[0]
                    option.distance = $0[1]
                }
                input.read(buffer, maxLength: 2)
                (0 ..< Int(buffer.withMemoryRebound(to: UInt16.self, capacity: 1) { $0[0] })).forEach { _ in
                    input.read(buffer, maxLength: 16)
                    option.points.append(buffer.withMemoryRebound(to: Double.self, capacity: 2) { ($0[0], $0[1]) })
                }
                item.options.append(option)
            }
            path.append(item)
        }
        while input.hasBytesAvailable && input.read(buffer, maxLength: 13) == 13 {
            let z = buffer.pointee
            let info = buffer.advanced(by: 1).withMemoryRebound(to: UInt32.self, capacity: 3) { $0 }
            let index = (input.property(forKey: .fileCurrentOffsetKey) as! NSNumber).intValue
            input.setProperty(NSNumber(value: index + Int(info[2])), forKey: .fileCurrentOffsetKey)
            cart.map["\(z).\(info[0]).\(info[1])"] = (index, Int(info[2]))
        }
        buffer.deallocate()
        input.close()
        return (path, cart)
    }
    
    public class func delete(_ id: String) {
        DispatchQueue.global(qos: .background).async {
            try? FileManager.default.removeItem(at: url(id))
        }
    }
    
    public class func share(_ item: Session.Item, result: @escaping((URL) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            let location: URL
            if item.name.isEmpty {
                location = temporal
            } else {
                location = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(item.name).argonaut")
            }
            let out = OutputStream(url: location, append: false)!
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
                result(location)
            }
        }
    }
    
    public class func receive(_ map: URL, result: @escaping((Session.Item) -> Void)) {
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
    
    class func save(_ factory: Factory) {
        prepare()
        let out = OutputStream(url: url(factory.item.id), append: false)!
        out.open()
        _ = [UInt8(factory.range.min()!), UInt8(factory.range.max()!), UInt8(factory.path.count)].withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 3) }
        factory.path.forEach {
            let name = Data($0.name.utf8)
            _ = withUnsafeBytes(of: UInt8(name.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
            if !name.isEmpty {
                _ = name.withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: name.count) }
            }
            _ = [$0.latitude, $0.longitude].withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: $0.count) }
            _ = withUnsafeBytes(of: UInt8($0.options.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
            $0.options.forEach {
                _ = withUnsafeBytes(of: UInt8($0.mode.rawValue)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 1) }
                _ = [$0.duration, $0.distance].withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: $0.count) }
                _ = withUnsafeBytes(of: UInt16($0.points.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 2) }
                if !$0.points.isEmpty {
                    _ = $0.points.withUnsafeBytes{ out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: $0.count) }
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
    
    class func code(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZMA))
            buffer.deallocate()
            return result
        }
    }

    class func decode(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let read = compression_decode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZMA)
            let result = Data(bytes: buffer, count: read)
            buffer.deallocate()
            return result
        }
    }
    
    private static func prepare() {
        var root = self.root
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try! root.setResourceValues(resources)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    private static func url(_ id: String) -> URL { return url.appendingPathComponent(id + ".argonaut") }
}
