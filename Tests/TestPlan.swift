@testable import Argonaut
import XCTest

final class TestPlan: XCTestCase {
    func testCode() {
        let factory = Factory()
        factory.plan.path = [.init(), .init()]
        factory.plan.path[0].name = "hello world"
        factory.item.id = "abc"
        Argonaut.save(factory)
        let coded = Argonaut.load("abc")
        XCTAssertEqual(2, coded.0.path.count)
        XCTAssertEqual("hello world", coded.0.path[0].name)
    }
    
    func testDecode() {
        let old = Factory()
        old.plan.path = [.init(), .init()]
        old.plan.path[0].name = "hello world"
        old.plan.path[0].latitude = 33.5
        old.plan.path[0].longitude = 23.5
        old.plan.path[0].options = [.init(), .init()]
        old.plan.path[0].options[0].mode = .driving
        old.plan.path[0].options[0].duration = 88.34
        old.plan.path[0].options[0].distance = 123.2
        old.plan.path[0].options[0].points = [(1.5, 2), (3, 4), (5, 6)]
        old.plan.path[1].name = "lorem ipsum"
        old.plan.path[1].latitude = 45.9
        old.plan.path[1].longitude = 90.1
        old.plan.path[1].options = [.init()]
        old.plan.path[1].options[0].points = [(99, 88)]
        old.item.id = "a"
        Argonaut.save(old)
        let new = Argonaut.load("a").0
        XCTAssertEqual(2, new.path.count)
        XCTAssertEqual("hello world", new.path[0].name)
        XCTAssertEqual(33.5, new.path[0].latitude)
        XCTAssertEqual(23.5, new.path[0].longitude)
        XCTAssertEqual(2, new.path[0].options.count)
        XCTAssertEqual(.driving, new.path[0].options[0].mode)
        XCTAssertEqual(.walking, new.path[0].options[1].mode)
        XCTAssertEqual(88.34, new.path[0].options[0].duration)
        XCTAssertEqual(123.2, new.path[0].options[0].distance)
        XCTAssertEqual(3, new.path[0].options[0].points.count)
        XCTAssertEqual(1.5, new.path[0].options[0].points[0].0)
        XCTAssertEqual(2, new.path[0].options[0].points[0].1)
        XCTAssertEqual(3, new.path[0].options[0].points[1].0)
        XCTAssertEqual(4, new.path[0].options[0].points[1].1)
        XCTAssertEqual("lorem ipsum", new.path[1].name)
        XCTAssertEqual(45.9, new.path[1].latitude)
        XCTAssertEqual(90.1, new.path[1].longitude)
        XCTAssertEqual(1, new.path[1].options.count)
        XCTAssertEqual(1, new.path[1].options[0].points.count)
    }
}
