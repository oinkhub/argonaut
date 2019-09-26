@testable import Argonaut
import XCTest
import MapKit

final class TestFactory: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testEmptyPlan() {
        factory.measure()
    }
    
    func testMeasure() {
        factory.path = [.init()]
        factory.path[0].options = [.init()]
        factory.path[0].options[0].points = [(-50, 60), (70, -80), (-30, 20), (82, -40)]
        factory.measure()
        XCTAssertEqual(-80.004, factory.rect.origin.coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(82.004, factory.rect.origin.coordinate.latitude, accuracy: 0.00001)
        XCTAssertEqual(60.004, MKMapPoint(x: factory.rect.maxX, y: 0).coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(-50.004, MKMapPoint(x: 0, y: factory.rect.maxY).coordinate.latitude, accuracy: 0.00001)
    }
    
    func testRegister() {
        factory.mode = .flying
        factory.path = [.init(), .init(), .init()]
        factory.path[0].name = "hello"
        factory.path[0].options = [.init()]
        factory.path[0].options[0].duration = 1
        factory.path[0].options[0].distance = 2
        factory.path[0].options[0].mode = .flying
        factory.path[1].name = "world"
        factory.path[1].options = [.init()]
        factory.path[1].options[0].duration = 1
        factory.path[1].options[0].distance = 2
        factory.path[1].options[0].mode = .flying
        factory.path[2].name = "lorem"
        factory.path[2].options = [.init()]
        factory.path[2].options[0].duration = 3
        factory.path[2].options[0].distance = 2
        factory.path[2].options[0].mode = .flying
        factory.register()
        XCTAssertEqual(.flying, factory.item.mode)
        XCTAssertEqual("hello", factory.item.points[0])
        XCTAssertEqual("world", factory.item.points[1])
        XCTAssertEqual("lorem", factory.item.points[2])
        XCTAssertEqual(5, factory.item.duration)
        XCTAssertEqual(6, factory.item.distance)
    }
    
    func testRegisterEmpty() {
        factory.register()
        XCTAssertTrue(factory.item.points.isEmpty)
    }
    
    func testRegisterNameNonEmpty() {
        factory.path = [.init(), .init()]
        factory.path[0].name = "hello"
        factory.register()
        XCTAssertEqual(1, factory.item.points.count)
    }
    
    func testRange() {
        factory.mode = .driving
        factory.filter()
        XCTAssertEqual(10, factory.range.min()!)
        XCTAssertEqual(19, factory.range.max()!)
        
        factory.mode = .flying
        factory.filter()
        XCTAssertEqual(1, factory.range.min()!)
        XCTAssertEqual(9, factory.range.max()!)
    }
}
