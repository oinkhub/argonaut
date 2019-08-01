import Foundation
import Compression

final class Press {
    func code(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let wrote = compression_encode_buffer(buffer, data.count * 10, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                  data.count, nil, COMPRESSION_ZLIB)
            let result = Data(bytes: buffer, count: wrote)
            buffer.deallocate()
            return result
        }
    }
}
