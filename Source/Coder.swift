import Foundation
import Compression

final class Coder {
    private let size = 100_000
    
    func code(_ from: URL, to: URL) {
        let input = InputStream(url: from)!
        let out = OutputStream(url: to, append: false)!
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        var status = compression_stream_init(&stream, COMPRESSION_STREAM_ENCODE, COMPRESSION_ZLIB)
        input.open()
        out.open()
        repeat {
            stream.src_size = input.read(buffer, maxLength: size)
            stream.src_ptr = UnsafePointer(buffer)
            stream.dst_ptr = buffer
            stream.dst_size = size
            status = compression_stream_process(&stream, stream.src_size < size ? Int32(COMPRESSION_STREAM_FINALIZE.rawValue) : 0)
            if size - stream.dst_size > 0 {
                out.write(buffer, maxLength: size - stream.dst_size)
            }
        } while status == COMPRESSION_STATUS_OK
        compression_stream_destroy(&stream)
        buffer.deallocate()
        input.close()
        out.close()
    }
}
