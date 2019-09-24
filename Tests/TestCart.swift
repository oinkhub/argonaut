@testable import Argonaut
import XCTest

final class TestCart: XCTestCase {
    private var factory: Factory!
    private var cart: Cart!
    private var split: Factory.Split!
    
    override func setUp() {
        try! FileManager.default.createDirectory(at: Argonaut.url, withIntermediateDirectories: true)
        factory = .init()
        split = .init()
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testTiles() {
        let expectA = expectation(description: "")
        let expectB = expectation(description: "")
        split.data = .init("hello world".utf8)
        split.x = 87
        split.y = 76
        factory.chunk([split], z: 1)
        split.data = .init("lorem ipsum".utf8)
        split.x = 45
        split.y = 12
        factory.chunk([split], z: 2)
        Argonaut.save(factory)
        cart = Argonaut.load(factory.item).1
        cart.tile(87, 76, 1) {
            XCTAssertEqual("hello world", String(decoding: $0!, as: UTF8.self))
            expectA.fulfill()
        }
        cart.tile(45, 12, 2) {
            XCTAssertEqual("lorem ipsum", String(decoding: $0!, as: UTF8.self))
            expectB.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testZoom() {
        factory.range = (55 ... 57)
        Argonaut.save(factory)
        XCTAssertEqual((55 ... 57), Argonaut.load(factory.item).1.zoom)
    }
    
    func testNil() {
        let expect = expectation(description: "")
        factory.chunk([split], z: 1)
        Argonaut.save(factory)
        cart = Argonaut.load(factory.item).1
        cart.tile(320, 560, 0) {
            XCTAssertNil($0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
