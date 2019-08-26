@testable import Argonaut
import XCTest
import Compression

final class TestCoder: XCTestCase {
    private var coder: Coder!
    private let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("coder")
    
    override func setUp() {
        coder = .init()
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
        coder.code(origin, to: destination)
        let data = try! Data(contentsOf: destination)
        XCTAssertEqual("hello world", String(decoding: data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 10000)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, 10000, $0.bindMemory(
                to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        } as Data, as: UTF8.self))
    }
}
