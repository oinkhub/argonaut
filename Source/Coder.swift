import Foundation
import Compression

final class Coder {
    class func code(_ data: Data, to: URL, operation: compression_stream_operation) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("argonaut.tmp")
        try! data.write(to: url, options: .atomic)
        code(url, to: to, operation: operation)
        try! FileManager.default.removeItem(at: url)
    }
    
    class func code(_ from: URL, operation: compression_stream_operation) -> Data {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("argonaut.tmp")
        code(from, to: url, operation: operation)
        let result = try! Data(contentsOf: url)
        try! FileManager.default.removeItem(at: url)
        return result
    }
    
    class func code(_ from: URL, operation: compression_stream_operation) -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("argonaut.tmp")
        code(from, to: url, operation: operation)
        return url
    }
    
    class func code(_ from: URL, to: URL, operation: compression_stream_operation) {
        let input = InputStream(url: from)!
        let out = OutputStream(url: to, append: false)!
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Argonaut.size)
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        var status = compression_stream_init(&stream, operation, COMPRESSION_ZLIB)
        input.open()
        out.open()
        repeat {
            stream.src_size = input.read(buffer, maxLength: Argonaut.size)
            stream.src_ptr = UnsafePointer(buffer)
            stream.dst_ptr = buffer
            stream.dst_size = Argonaut.size
            status = compression_stream_process(&stream, stream.src_size < Argonaut.size ? Int32(COMPRESSION_STREAM_FINALIZE.rawValue) : 0)
            if Argonaut.size - stream.dst_size > 0 {
                out.write(buffer, maxLength: Argonaut.size - stream.dst_size)
            }
        } while status == COMPRESSION_STATUS_OK
        compression_stream_destroy(&stream)
        buffer.deallocate()
        input.close()
        out.close()
    }
    
    class func code(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        }
    }
    
    class func decode(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, data.count * 10, $0.bindMemory(
                to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        }
    }
}
