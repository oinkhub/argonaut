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
        XCTAssertEqual(99, factory.content.first)
        XCTAssertEqual(87, factory.content.subdata(in: 1 ..< 5).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(76, factory.content.subdata(in: 5 ..< 9).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, factory.content.subdata(in: 9 ..< 13).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("hello world", String(decoding: factory.content.subdata(in: 13 ..< 24), as: UTF8.self))
        
        factory.chunk(.init("lorem ipsum".utf8), tile: 42, x: 21, y: 67)
        XCTAssertEqual(2, factory.chunks)
        XCTAssertEqual(42, factory.content[24])
        XCTAssertEqual(21, factory.content.subdata(in: 25 ..< 29).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(67, factory.content.subdata(in: 29 ..< 33).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, factory.content.subdata(in: 33 ..< 37).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("lorem ipsum", String(decoding: factory.content.subdata(in: 37 ..< 48), as: UTF8.self))
    }
    
    func testWrap() {
        factory.chunk(.init("hello world".utf8), tile: 99, x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), tile: 23, x: 34, y: 12)
        factory.item.id = "abc"
        Argonaut.save(factory)
        let cart = Argonaut.load("abc").1
        XCTAssertEqual(2, cart.map.keys.count)
        XCTAssertNotNil(cart.tile(99, x: 87, y: 76))
    }
}
