@testable import Argonaut
import XCTest

final class TestChunk: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testAdd() {
        factory.chunk(.init("hello world".utf8), tile: 99, x: 87, y: 76)
        XCTAssertEqual(1, factory.chunks)
        var data = try! Data(contentsOf: Argonaut.temporal)
        XCTAssertEqual(99, data.first)
        XCTAssertEqual(87, data.subdata(in: 1 ..< 5).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(76, data.subdata(in: 5 ..< 9).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, data.subdata(in: 9 ..< 13).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("hello world", String(decoding: data.subdata(in: 13 ..< 24), as: UTF8.self))
        
        factory.chunk(.init("lorem ipsum".utf8), tile: 42, x: 21, y: 67)
        XCTAssertEqual(2, factory.chunks)
        data = try! Data(contentsOf: Argonaut.temporal)
        XCTAssertEqual(42, data[24])
        XCTAssertEqual(21, data.subdata(in: 25 ..< 29).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(67, data.subdata(in: 29 ..< 33).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, data.subdata(in: 33 ..< 37).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("lorem ipsum", String(decoding: data.subdata(in: 37 ..< 48), as: UTF8.self))
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
