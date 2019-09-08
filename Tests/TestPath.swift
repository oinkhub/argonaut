@testable import Argonaut
import XCTest

final class TestPath: XCTestCase {
    override class func setUp() {
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testCode() {
        var factory: Factory! = Factory()
        factory.path = [.init(), .init()]
        factory.path[0].name = "hello world"
        factory.item.id = "abc"
        Argonaut.save(factory)
        factory = nil
        let coded = Argonaut.load("abc")
        XCTAssertEqual(2, coded.0.count)
        XCTAssertEqual("hello world", coded.0[0].name)
    }
    
    func testDecode() {
        let old = Factory()
        old.path = [.init(), .init()]
        old.path[0].name = "hello world"
        old.path[0].latitude = 33.5
        old.path[0].longitude = 23.5
        old.path[0].options = [.init(), .init()]
        old.path[0].options[0].duration = 88.34
        old.path[0].options[0].distance = 123.2
        old.path[0].options[0].points = [(1.5, 2), (3, 4), (5, 6)]
        old.path[1].name = "lorem ipsum"
        old.path[1].latitude = 45.9
        old.path[1].longitude = 90.1
        old.path[1].options = [.init()]
        old.path[1].options[0].points = [(99, 88)]
        old.item.id = "a"
        Argonaut.save(old)
        let new = Argonaut.load("a").0
        XCTAssertEqual(2, new.count)
        XCTAssertEqual("hello world", new[0].name)
        XCTAssertEqual(33.5, new[0].latitude)
        XCTAssertEqual(23.5, new[0].longitude)
        XCTAssertEqual(2, new[0].options.count)
        XCTAssertEqual(.walking, new[0].options[0].mode)
        XCTAssertEqual(.walking, new[0].options[1].mode)
        XCTAssertEqual(88.34, new[0].options[0].duration)
        XCTAssertEqual(123.2, new[0].options[0].distance)
        XCTAssertEqual(3, new[0].options[0].points.count)
        XCTAssertEqual(1.5, new[0].options[0].points[0].0)
        XCTAssertEqual(2, new[0].options[0].points[0].1)
        XCTAssertEqual(3, new[0].options[0].points[1].0)
        XCTAssertEqual(4, new[0].options[0].points[1].1)
        XCTAssertEqual("lorem ipsum", new[1].name)
        XCTAssertEqual(45.9, new[1].latitude)
        XCTAssertEqual(90.1, new[1].longitude)
        XCTAssertEqual(1, new[1].options.count)
        XCTAssertEqual(1, new[1].options[0].points.count)
    }
    
    func testNoName() {
        let old = Factory()
        old.item.id = "a"
        old.path = [.init()]
        old.path[0].options = [.init()]
        Argonaut.save(old)
        let new = Argonaut.load("a").0
        XCTAssertEqual("", new[0].name)
        XCTAssertEqual(1, new[0].options.count)
    }
    
    func testOnlyActiveMode() {
        let old = Factory()
        old.item.id = "a"
        old.mode = .flying
        old.path = [.init()]
        old.path[0].options = [.init(), .init(), .init()]
        old.path[0].options[0].mode = .driving
        old.path[0].options[1].mode = .walking
        old.path[0].options[2].mode = .flying
        old.filter()
        Argonaut.save(old)
        let new = Argonaut.load("a").0
        XCTAssertEqual(1, new[0].options.count)
        XCTAssertEqual(.flying, new[0].options[0].mode)
    }
}
