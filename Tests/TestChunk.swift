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
        let data = try! Data(contentsOf: Argonaut.temporal)
        XCTAssertEqual(87, data.subdata(in: 0 ..< 4).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(76, data.subdata(in: 4 ..< 8).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
    }
    
    func testWrap() {
        factory.chunk(.init("hello world".utf8), x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), x: 34, y: 12)
        factory.item.id = "abc"
        Argonaut.save(factory)
        let cart = Argonaut.load("abc").1
        XCTAssertEqual(2, cart.map.keys.count)
        XCTAssertNotNil(cart.tile(87, 76))
    }
}
