import Foundation
import Compression

public final class Argonaut {
    public static let tile = 512.0
    static let size = 100_000
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    static let temporal = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("map.argonaut")
    
    public static func save(_ id: String, data: Data) {
        prepare()
        try! code(data).write(to: url(id), options: .atomic)
    }
    
    public static func load(_ id: String) -> (Plan, Cart) {
        let data = Coder().code(url(id), operation: COMPRESSION_STREAM_DECODE)
        let plan = Plan()
        let cart = Cart(data.subdata(in: plan.decode(data) ..< data.count))
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
            let coded = code(try! JSONEncoder().encode(item))
            _ = withUnsafeBytes(of: UInt16(coded.count)) { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: 2) }
            _ = coded.withUnsafeBytes { out.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: coded.count) }
            let input = InputStream(url: url(item.id))!
            input.open()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
            while input.hasBytesAvailable {
                let size = input.read(buffer, maxLength: 4096)
                if size < 1 {
                    break
                }
                out.write(buffer, maxLength: size)
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
            let item = try! JSONDecoder().decode(Session.Item.self, from: Coder().decode(.init(bytes: buffer, count: input.read(buffer, maxLength: Int(buffer.withMemoryRebound(to: UInt16.self, capacity: 1) { $0.pointee })))))
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
    
    private static func prepare() {
        var url = self.url
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try! url.setResourceValues(resources)
    }
    
    private static func url(_ id: String) -> URL { return url.appendingPathComponent(id + ".argonaut") }
    
    private static func code(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        }
    }
}
