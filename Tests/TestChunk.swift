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
        factory.chunk(.init("hello world".utf8), x: 87, y: 76)
        var data = try! Data(contentsOf: Argonaut.temporal)
        XCTAssertEqual(87, data.subdata(in: 0 ..< 4).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(76, data.subdata(in: 4 ..< 8).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, data.subdata(in: 8 ..< 12).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("hello world", String(decoding: data.subdata(in: 12 ..< 23), as: UTF8.self))
        
        factory.chunk(.init("lorem ipsum".utf8), x: 21, y: 67)
        data = try! Data(contentsOf: Argonaut.temporal)
        XCTAssertEqual(21, data.subdata(in: 23 ..< 27).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(67, data.subdata(in: 27 ..< 31).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(11, data.subdata(in: 31 ..< 35).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual("lorem ipsum", String(decoding: data.subdata(in: 35 ..< 46), as: UTF8.self))
    }
    
    func testWrap() {
        factory.chunk(.init("hello world".utf8), x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), x: 34, y: 12)
        factory.item.id = "abc"
        Argonaut.save(factory)
        let cart = Argonaut.load("abc").1
        print(cart.map)
        XCTAssertEqual(2, cart.map.keys.count)
        XCTAssertNotNil(cart.tile(87, 76))
    }
}
