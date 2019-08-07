import Foundation
import Compression

public final class Argonaut {
    public static let tile = 512.0
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("maps")
    
    public static func save(_ id: String, data: Data) {
        try! code(data).write(to: url.appendingPathComponent(id + ".argonaut"), options: .atomic)
    }
    
    public static func load(_ id: String) -> (Plan, Cart) {
        let data = decode(try! Data(contentsOf: url.appendingPathComponent(id + ".argonaut")))
        let plan = Plan()
        let cart = Cart(data.subdata(in: plan.decode(data) ..< data.count))
        return (plan, cart)
    }
    
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
