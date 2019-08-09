@testable import Argonaut
import XCTest

final class TestArgonaut: XCTestCase {
    override class func setUp() {
        try! FileManager.default.createDirectory(at: Argonaut.url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Argonaut.url)
    }
    
    func testDelete() {
        let expect = expectation(description: "")
        let url = Argonaut.url.appendingPathComponent("lorem.argonaut")
        try! Data("hello world".utf8).write(to: url)
        Argonaut.delete("lorem")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.05) {
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
