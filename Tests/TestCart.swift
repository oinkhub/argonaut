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
        cart.tile(87, 76) {
            XCTAssertEqual("hello world", String(decoding: $0!, as: UTF8.self))
            expectA.fulfill()
        }
        cart.tile(45, 12) {
            XCTAssertEqual("lorem ipsum", String(decoding: $0!, as: UTF8.self))
            expectB.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testZoom() {
        factory.item.id = "abc"
        factory.range = (55 ... 57)
        Argonaut.save(factory)
        XCTAssertEqual((55 ... 57), Argonaut.load("abc").1.zoom)
    }
    
    func testNil() {
        let expect = expectation(description: "")
        factory.chunk(.init("hello world".utf8), x: 160, y: 280)
        factory.item.id = "abc"
        Argonaut.save(factory)
        cart = Argonaut.load("abc").1
        cart.tile(320, 560) {
            XCTAssertNil($0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
