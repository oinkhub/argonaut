@testable import Argonaut
import XCTest

final class TestChunk: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = Factory()
    }
    
    func testAdd() {
        var chunk = Data("hello world".utf8)
        factory.chunk(chunk, tile: 99, x: 87, y: 76)
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
        
        chunk = Data("lorem ipsum".utf8)
        factory.chunk(chunk, tile: 42, x: 21, y: 67)
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
}
