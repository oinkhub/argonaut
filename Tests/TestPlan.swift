@testable import Argonaut
import XCTest

final class TestPlan: XCTestCase {
    func testCode() {
        let plan = Plan()
        plan.path = [.init(), .init()]
        plan.path[0].name = "hello world"
        let coded = plan.code()
        XCTAssertEqual(2, coded[0])
        XCTAssertEqual(11, coded[1])
        XCTAssertEqual("hello world", String(decoding: coded.subdata(in: 2 ..< 13), as: UTF8.self))
    }
    
    func testDecode() {
        let old = Plan()
        old.path = [.init(), .init()]
        old.path[0].name = "hello world"
        old.path[0].latitude = 33.5
        old.path[0].longitude = 23.5
        old.path[0].options = [.init(), .init()]
        old.path[0].options[0].mode = .driving
        old.path[0].options[0].duration = 88.34
        old.path[0].options[0].distance = 123.2
        old.path[0].options[0].points = [(1.5, 2), (3, 4), (5, 6)]
        old.path[1].name = "lorem ipsum"
        old.path[1].latitude = 45.9
        old.path[1].longitude = 90.1
        old.path[1].options = [.init()]
        old.path[1].options[0].points = [(99, 88)]
        
        let new = Plan()
        _ = new.decode(old.code())
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
