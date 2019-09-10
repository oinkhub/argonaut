@testable import Argonaut
import XCTest

final class TestArgonaut: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        try! FileManager.default.createDirectory(at: Argonaut.url, withIntermediateDirectories: true)
        factory = .init()
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
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
        item.distance = 8.8
        item.duration = 7.5
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
                    XCTAssertEqual(item.distance, $0.distance)
                    XCTAssertEqual(item.duration, $0.duration)
                    XCTAssertEqual("hello world", String(decoding: try! Data(contentsOf: url), as: UTF8.self))
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoad() {
        let expectA = expectation(description: "")
        let expectB = expectation(description: "")
        factory.chunk(.init("hello world".utf8), x: 87, y: 76, z: 1)
        factory.chunk(.init("lorem ipsum dolec".utf8), x: 45, y: 12, z: 2)
        factory.path = [.init(), .init()]
        factory.path[0].name = "hello"
        factory.path[0].options = [.init()]
        factory.path[0].options[0].points = [(-50, 60), (70, -80), (-30, 20), (82, -40)]
        factory.path[1].name = "adasdsadas dadskjnaslkdas sakmdasklmdas asmdkaslmdlksama sdksamdklasmklsa asdsaasd\n sdadas"
        factory.item.id = "abc"
        Argonaut.save(factory)
        factory = nil
        let loaded = Argonaut.load("abc")
        XCTAssertEqual(-50, loaded.0[0].options[0].points[0].0)
        XCTAssertEqual(60, loaded.0[0].options[0].points[0].1)
        XCTAssertEqual(70, loaded.0[0].options[0].points[1].0)
        XCTAssertEqual(-80, loaded.0[0].options[0].points[1].1)
        XCTAssertEqual(-30, loaded.0[0].options[0].points[2].0)
        XCTAssertEqual(20, loaded.0[0].options[0].points[2].1)
        XCTAssertEqual(82, loaded.0[0].options[0].points[3].0)
        XCTAssertEqual(-40, loaded.0[0].options[0].points[3].1)
        XCTAssertEqual("hello", loaded.0[0].name)
        XCTAssertEqual("adasdsadas dadskjnaslkdas sakmdasklmdas asmdkaslmdlksama sdksamdklasmklsa asdsaasd\n sdadas", loaded.0[1].name)
        loaded.1.tile(87, 76, 1) {
            XCTAssertEqual("hello world", String(decoding: $0!, as: UTF8.self))
            expectA.fulfill()
        }
        loaded.1.tile(45, 12, 2) {
            XCTAssertEqual("lorem ipsum dolec", String(decoding: $0!, as: UTF8.self))
            expectB.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveRemovesTemporal() {
        Argonaut.save(.init())
        XCTAssertFalse(FileManager.default.fileExists(atPath: Argonaut.temporal.path))
    }
}
