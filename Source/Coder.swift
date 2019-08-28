import Foundation
import Compression

final class Coder {
    class func decode(_ from: URL) -> URL {
        code(from, to: Argonaut.temporal, operation: COMPRESSION_STREAM_DECODE)
        return Argonaut.temporal
    }
    
    class func code(_ from: URL, to: URL, operation: compression_stream_operation = COMPRESSION_STREAM_ENCODE) {
        let input = InputStream(url: from)!
        let out = OutputStream(url: to, append: false)!
        let reading = UnsafeMutablePointer<UInt8>.allocate(capacity: Argonaut.size)
        let writing = UnsafeMutablePointer<UInt8>.allocate(capacity: Argonaut.size)
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        var status = compression_stream_init(&stream, operation, COMPRESSION_LZFSE)
        var read = 0
        input.open()
        out.open()
        repeat {
            var flag = Int32()
            if stream.src_size == 0 {
                read = input.read(reading, maxLength: Argonaut.size)
                stream.src_size = read
                if read < Argonaut.size {
                    flag = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                }
            }
            stream.src_ptr = UnsafePointer(reading).advanced(by: read - stream.src_size)
            stream.dst_ptr = writing
            stream.dst_size = Argonaut.size
            status = compression_stream_process(&stream, flag)
            out.write(writing, maxLength: Argonaut.size - stream.dst_size)
        } while status == COMPRESSION_STATUS_OK
        compression_stream_destroy(&stream)
        reading.deallocate()
        writing.deallocate()
        input.close()
        out.close()
    }
    
    class func code(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZFSE))
            buffer.deallocate()
            return result
        }
    }
    
    class func decode(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, data.count * 10, $0.bindMemory(
                to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZFSE))
            buffer.deallocate()
            return result
        }
    }
}
