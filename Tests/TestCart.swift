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
        cart = .init(factory.wrap())
        XCTAssertNil(cart.tile(99, x: 88, y: 76))
        XCTAssertEqual("hello world", String(decoding: cart.tile(99, x: 87, y: 76) ?? Data(), as: UTF8.self))
    }
}
