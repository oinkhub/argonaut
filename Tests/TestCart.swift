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
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testTiles() {
        factory.chunk(.init("hello world".utf8), x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), x: 45, y: 12)
        factory.item.id = "abc"
        Argonaut.save(factory)
        cart = Argonaut.load("abc").1
        XCTAssertEqual("hello world", String(decoding: cart.tile(87, 76)!, as: UTF8.self))
        XCTAssertEqual("lorem ipsum", String(decoding: cart.tile(45, 12)!, as: UTF8.self))
    }
    
    func testNil() {
        factory.chunk(.init("hello world".utf8), x: 160, y: 280)
        factory.item.id = "abc"
        Argonaut.save(factory)
        cart = Argonaut.load("abc").1
        XCTAssertNil(cart.tile(320, 560))
    }
}
