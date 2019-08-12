@testable import Argonaut
import XCTest

final class TestChunk: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init()
    }
    
    func testAdd() {
        factory.chunk(.init("hello world".utf8), tile: 99, x: 87, y: 76)
        XCTAssertEqual(1, factory.chunks)
        XCTAssertEqual(99, factory.info.first)
        XCTAssertEqual(87, factory.info.subdata(in: 1 ..< 5).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(76, factory.info.subdata(in: 5 ..< 9).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(0, factory.info.subdata(in: 9 ..< 13).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, factory.info.subdata(in: 13 ..< 17).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("hello world", String(decoding: factory.content.subdata(in: 0 ..< 11), as: UTF8.self))
        
        factory.chunk(.init("lorem ipsum".utf8), tile: 42, x: 21, y: 67)
        XCTAssertEqual(2, factory.chunks)
        XCTAssertEqual(42, factory.info[17])
        XCTAssertEqual(21, factory.info.subdata(in: 18 ..< 22).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(67, factory.info.subdata(in: 22 ..< 26).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, factory.info.subdata(in: 26 ..< 30).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, factory.info.subdata(in: 30 ..< 34).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("lorem ipsum", String(decoding: factory.content.subdata(in: 11 ..< 22), as: UTF8.self))
    }
    
    func testWrap() {
        factory.chunk(.init("hello world".utf8), tile: 99, x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), tile: 23, x: 34, y: 12)
        let wrapped = factory.wrap()
        XCTAssertEqual(2, wrapped.subdata(in: 1 ..< 5).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(99, wrapped[5])
    }
}
