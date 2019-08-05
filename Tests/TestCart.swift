@testable import Argonaut
import XCTest

final class TestCart: XCTestCase {
    private var factory: Factory!
    private var cart: Cart!
    
    override func setUp() {
        factory = .init(.init())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Argonaut.url.appendingPathComponent("test.argonaut"))
    }
    
    func testTiles() {
        factory.chunk(.init("hello world".utf8), tile: 99, x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), tile: 34, x: 45, y: 12)
        try! FileManager.default.createDirectory(at: Argonaut.url, withIntermediateDirectories: true)
        try! factory.wrap().write(to: Argonaut.url.appendingPathComponent("test.argonaut"), options: .atomic)
        cart = .init("test")
        XCTAssertNil(cart.map["99-88.76"])
        XCTAssertEqual("hello world", String(decoding: cart.map["99-87.76"]!, as: UTF8.self))
        XCTAssertEqual("lorem ipsum", String(decoding: cart.map["34-45.12"]!, as: UTF8.self))
    }
}
