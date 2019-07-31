@testable import Argonaut
import XCTest

final class TestChunk: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = Factory()
    }
    
    func testAdd() {
        var chunk = Data("hello world".utf8)
        factory.chunk(chunk, tile: 99, x: 87, y: 76)
        XCTAssertEqual(1, factory.chunks)
        XCTAssertEqual(99, factory.data.subdata(in: 0 ..< 4).withUnsafeBytes({
            UnsafeBufferPointer<UInt32>(start: $0, count: 4).map(UInt32.init(littleEndian:))
        }).first)
    }
}
