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
        let expectA = expectation(description: "")
        let expectB = expectation(description: "")
        factory.chunk(.init("hello world".utf8), x: 87, y: 76)
        factory.chunk(.init("lorem ipsum".utf8), x: 45, y: 12)
        factory.item.id = "abc"
        Argonaut.save(factory)
        cart = Argonaut.load("abc").1
        _ = cart.tile(87, 76) {
            XCTAssertEqual("hello world", String(decoding: self.cart.tile(87, 76)!, as: UTF8.self))
            expectA.fulfill()
        }
        _ = cart.tile(45, 12) {
            XCTAssertEqual("lorem ipsum", String(decoding: self.cart.tile(45, 12)!, as: UTF8.self))
            expectB.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNil() {
        let expect = expectation(description: "")
        factory.chunk(.init("hello world".utf8), x: 160, y: 280)
        factory.item.id = "abc"
        Argonaut.save(factory)
        cart = Argonaut.load("abc").1
        _ = cart.tile(320, 560) {
            XCTAssertNil(self.cart.tile(320, 560))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCache() {
        let expect = expectation(description: "")
        factory.chunk(.init("hello world".utf8), x: 1, y: 1)
        factory.chunk(.init("lorem ipsum".utf8), x: 2, y: 2)
        factory.chunk(.init("lorem ipsum".utf8), x: 3, y: 3)
        factory.item.id = "abc"
        Argonaut.save(factory)
        cart = Argonaut.load("abc").1
        cart.limit = 2
        _ = cart.tile(1, 1)
        _ = cart.tile(2, 2)
        _ = cart.tile(3, 3) {
            XCTAssertEqual(2, self.cart.cache.count)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
