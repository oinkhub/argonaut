@testable import Argonaut
import XCTest

final class TestArgonaut: XCTestCase {
    override func setUp() {
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
    
    func testShare() {
        let expect = expectation(description: "")
        let url = Argonaut.url.appendingPathComponent("lorem.argonaut")
        try! Data("hello world".utf8).write(to: url)
        let item = Session.Item()
        item.id = "lorem"
        item.title = "hello world and lorem ipsum"
        item.origin = "alpha"
        item.destination = "beta"
        item.walking.distance = 8.8
        item.walking.duration = 7.5
        Argonaut.share(item) { shared in
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try! FileManager.default.removeItem(at: url)
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
            
            XCTAssertEqual(.main, Thread.current)
            XCTAssertTrue(FileManager.default.fileExists(atPath: shared.path))
            DispatchQueue.global(qos: .background).async {
                Argonaut.receive(shared) {
                    XCTAssertEqual(.main, Thread.current)
                    XCTAssertEqual(item.id, $0.id)
                    XCTAssertEqual(item.title, $0.title)
                    XCTAssertEqual(item.origin, $0.origin)
                    XCTAssertEqual(item.destination, $0.destination)
                    XCTAssertEqual(item.walking.distance, $0.walking.distance)
                    XCTAssertEqual(item.walking.duration, $0.walking.duration)
                    XCTAssertEqual("hello world", String(decoding: try! Data(contentsOf: url), as: UTF8.self))
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
