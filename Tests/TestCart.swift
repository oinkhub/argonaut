@testable import Argonaut
import XCTest

final class TestCart: XCTestCase {
    private var factory: Factory!
    private var cart: Cart!
    
    override func setUp() {
        try! FileManager.default.createDirectory(at: Argonaut.url, withIntermediateDirectories: true)
        factory = .init()
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Argonaut.url)
    }
    
    func testTiles() {
        factory.chunk(.init("hello world".utf8), tile: 99, x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), tile: 34, x: 45, y: 12)
        Argonaut.save("abc", data: factory.wrap())
        cart = Argonaut.load("abc").1
        XCTAssertEqual("hello world", String(decoding: cart.tile(99, x: 87, y: 76)!, as: UTF8.self))
        XCTAssertEqual("lorem ipsum", String(decoding: cart.tile(34, x: 45, y: 12)!, as: UTF8.self))
    }
    
    func testAlternate() {
        factory.chunk(.init("hello world".utf8), tile: 16, x: 160, y: 280)
        Argonaut.save("abc", data: factory.wrap())
        cart = Argonaut.load("abc").1
        XCTAssertTrue(cart.tile(17, x: 320, y: 560)?.isEmpty == true)
        XCTAssertNil(cart.tile(11, x: 320, y: 560))
    }
}
