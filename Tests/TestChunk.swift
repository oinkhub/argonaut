@testable import Argonaut
import XCTest
import Compression

final class TestChunk: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init(.init())
    }
    
    func testAdd() {
        factory.chunk(Data("hello world".utf8), tile: 99, x: 87, y: 76)
        XCTAssertEqual(1, factory.chunks)
        XCTAssertEqual(99, factory.data.first)
        XCTAssertEqual(87, factory.data.subdata(in: 1 ..< 5).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(76, factory.data.subdata(in: 5 ..< 9).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(0, factory.data.subdata(in: 9 ..< 13).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(11, factory.data.subdata(in: 13 ..< 17).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual("hello world", String(decoding: factory.data.subdata(in: 17 ..< 28), as: UTF8.self))
        
        factory.chunk(Data("lorem ipsum".utf8), tile: 42, x: 21, y: 67)
        XCTAssertEqual(2, factory.chunks)
        XCTAssertEqual(42, factory.data.first)
        XCTAssertEqual(21, factory.data.subdata(in: 1 ..< 5).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(67, factory.data.subdata(in: 5 ..< 9).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(28, factory.data.subdata(in: 9 ..< 13).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(11, factory.data.subdata(in: 13 ..< 17).withUnsafeBytes({
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual("lorem ipsum", String(decoding: factory.data.subdata(in: 45 ..< 56), as: UTF8.self))
    }
    
    func testWrap() {
        factory.chunk(Data("hello world".utf8), tile: 99, x: 87, y: 76)
        let wrapped = factory.wrap()
        let unwrapped = wrapped.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, 1024, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), wrapped.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        } as Data
        XCTAssertEqual(1, unwrapped.subdata(in: 0 ..< 4).withUnsafeBytes({ $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(99, unwrapped[4])
    }
}
