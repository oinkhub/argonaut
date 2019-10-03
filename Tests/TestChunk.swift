@testable import Argo
import XCTest

final class TestChunk: XCTestCase {
    private var factory: Factory!
    private var split: Factory.Split!
    
    override func setUp() {
        factory = .init()
        split = .init()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testAdd() {
        split.data = .init("hello world".utf8)
        split.x = 87
        split.y = 76
        factory.chunk([split], z: 0)
        let data = try! Data(contentsOf: Argonaut.temporal)
        XCTAssertEqual(87, data.subdata(in: 1 ..< 5).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        XCTAssertEqual(76, data.subdata(in: 5 ..< 9).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
    }
    
    func testWrap() {
        let expect = expectation(description: "")
        split.data = .init("hello world".utf8)
        split.x = 87
        split.y = 76
        factory.chunk([split], z: 3)
        split.data = .init("lorem ipsum".utf8)
        split.x = 34
        split.y = 12
        factory.chunk([split], z: 4)
        Argonaut.save(factory)
        let cart = Argonaut.load(factory.item).1
        XCTAssertEqual(2, cart.map.keys.count)
        cart.tile(87, 76, 3) {
            XCTAssertNotNil($0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
