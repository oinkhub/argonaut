@testable import Argonaut
import XCTest
import Compression

final class TestPlan: XCTestCase {
    private var plan: Plan!
    
    override func setUp() {
        plan = .init()
        plan.route = [.init(.init(latitude: 33, longitude: 44)), .init(.init(latitude: 21, longitude: 56))]
    }
    
    func testCode() {
        plan.route[0].mark.name = "hello world"
        plan.route[0].path = [MockRoute([(1, 2), (3, 4), (5, 6)])]
        plan.route[1].mark.name = "lorem ipsum"
        plan.route[1].path = [MockRoute([(99, 88)])]
        let coded = plan.code()
        let unwrapped = coded.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
            let result = Data(bytes: buffer, count: compression_decode_buffer(buffer, 1024, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), coded.count, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        } as Data
        
        XCTAssertEqual(2, unwrapped.subdata(in: 0 ..< 4).withUnsafeBytes({ $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
        XCTAssertEqual(2, unwrapped.subdata(in: 0 ..< 4).withUnsafeBytes({ $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1).pointee }))
    }
}
