@testable import Argonaut
import XCTest
import Compression

final class TestPlan: XCTestCase {
    func testCode() {
        let plan = Plan()
        plan.path = [.init(), .init()]
        plan.path[0].name = "hello world"
        plan.path[0].options = [.init()]
        plan.path[0].options[0].points = [(1, 2), (3, 4), (5, 6)]
        plan.path[1].name = "lorem ipsum"
        plan.path[1].options = [.init()]
        plan.path[1].options[0].points = [(99, 88)]
        let coded = plan.code()
        let unwrapped = coded.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, 1024, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), coded.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        } as Data
//        XCTAssertEqual(2, unwrapped.subdata(in: 0 ..< 4).withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee })
    }
}
