import Foundation
import Compression

public final class Argonaut {
    public static let tile = 512.0
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    private static let temporal = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("map.argonaut")
    
    public static func save(_ id: String, data: Data) {
        prepare()
        try! code(data).write(to: url(id), options: .atomic)
    }
    
    public static func load(_ id: String) -> (Plan, Cart) {
        let data = decode(try! Data(contentsOf: url(id)))
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
            let coded = code(try! JSONEncoder().encode(item))
            var data = Data()
            withUnsafeBytes(of: UInt16(coded.count)) { data += $0 }
            data += coded
            data += try! Data(contentsOf: url(item.id))
            try! data.write(to: temporal, options: .atomic)
            DispatchQueue.main.async {
                result(temporal)
            }
        }
    }
    
    public static func receive(_ map: URL, result: @escaping((Session.Item) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            guard map.pathExtension == "argonaut" else { return }
            prepare()
            let data = try! Data(contentsOf: map)
            let count = Int(data.subdata(in: 0 ..< 2).withUnsafeBytes { $0.bindMemory(to: UInt16.self)[0] })
            let item = try! JSONDecoder().decode(Session.Item.self, from: decode(data.subdata(in: 2 ..< count + 2)))
            try! data.subdata(in: 2 + count ..< data.count).write(to: url(item.id), options: .atomic)
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
    
    private static func decode(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, data.count * 10, $0.bindMemory(
                to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        }
    }
}
