@testable import Argonaut
import XCTest
import Compression

final class TestPlan: XCTestCase {
    func testCode() {
        let plan = Plan()
        plan.path = [.init(), .init()]
        plan.path[0].name = "hello world"
        let coded = plan.code()
        let unwrapped = coded.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, 1024, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), coded.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        } as Data
        XCTAssertEqual(2, unwrapped[0])
        XCTAssertEqual(11, unwrapped[1])
        XCTAssertEqual("hello world", String(decoding: unwrapped.subdata(in: 2 ..< 13), as: UTF8.self))
    }
    
    func testDecode() {
        let old = Plan()
        old.path = [.init(), .init()]
        old.path[0].name = "hello world"
        old.path[0].latitude = 33.5
        old.path[0].longitude = 23.5
        old.path[0].options = [.init()]
        old.path[0].options[0].points = [(1, 2), (3, 4), (5, 6)]
        old.path[1].name = "lorem ipsum"
        old.path[1].options = [.init()]
        old.path[1].options[0].points = [(99, 88)]
        
        let new = Plan()
        new.decode(old.code())
        XCTAssertEqual(2, new.path.count)
        XCTAssertEqual("hello world", new.path[0].name)
        XCTAssertEqual(33.5, new.path[0].latitude)
        XCTAssertEqual(23.5, new.path[0].longitude)
        XCTAssertEqual("lorem ipsum", new.path[1].name)
    }
}
