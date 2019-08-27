@testable import Argonaut
import XCTest
import Compression

final class TestCoder: XCTestCase {
    private let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("coder")
    
    override func setUp() {
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testCodeURL() {
        let origin = url.appendingPathComponent("some.file")
        let destination = url.appendingPathComponent("other.file")
        try! Data("hello world".utf8).write(to: origin)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        Coder.code(origin, to: destination)
        let data = try! Data(contentsOf: destination)
        XCTAssertEqual("hello world", String(decoding: data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 10000)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, 10000, $0.bindMemory(
                to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZFSE))
            buffer.deallocate()
            return result
        } as Data, as: UTF8.self))
    }
    
    func testDecodeUrl() {
        let origin = url.appendingPathComponent("some.file")
        let destination = url.appendingPathComponent("other.file")
        let data = Data("hello world".utf8)
        try! (data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 10000)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, 10000, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZFSE))
            buffer.deallocate()
            return result
        } as Data).write(to: origin, options: .atomic)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        Coder.code(origin, to: destination, operation: COMPRESSION_STREAM_DECODE)
        XCTAssertEqual("hello world", try! String(decoding: Data(contentsOf: destination), as: UTF8.self))
    }
    
    func testReceiveUrl() {
        let origin = url.appendingPathComponent("some.file")
        let data = Data("hello world".utf8)
        try! (data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 10000)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, 10000, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZFSE))
            buffer.deallocate()
            return result
        } as Data).write(to: origin, options: .atomic)
        XCTAssertEqual("hello world", try! String(decoding: Data(contentsOf: Coder.decode(origin)), as: UTF8.self))
    }
}
