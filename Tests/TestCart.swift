@testable import Argonaut
import XCTest

final class TestCart: XCTestCase {
    private var factory: Factory!
    private var cart: Cart!
    
    override func setUp() {
        factory = .init(.init())
    }
    
    func testTiles() {
        factory.chunk(.init("hello world".utf8), tile: 99, x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), tile: 34, x: 45, y: 12)
        cart = .init(factory.wrap())
        XCTAssertNil(cart.tile(99, x: 88, y: 76))
        XCTAssertEqual("hello world", String(decoding: cart.tile(99, x: 87, y: 76)!, as: UTF8.self))
        XCTAssertEqual("lorem ipsum", String(decoding: cart.tile(34, x: 45, y: 12)!, as: UTF8.self))
    }
}
