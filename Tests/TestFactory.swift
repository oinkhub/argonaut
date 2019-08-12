@testable import Argonaut
import XCTest
import MapKit

final class TestFactory: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init()
    }
    
    func testEmptyPlan() {
        factory.measure()
    }
    
    func testMeasure() {
        factory.plan.path = [.init()]
        factory.plan.path[0].options = [.init()]
        factory.plan.path[0].options[0].points = [(-50, 60), (70, -80), (-30, 20), (82, -40)]
        factory.measure()
        XCTAssertEqual(-80.002, factory.rect.origin.coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(82.002, factory.rect.origin.coordinate.latitude, accuracy: 0.00001)
        XCTAssertEqual(60.002, MKMapPoint(x: factory.rect.maxX, y: 0).coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(-50.002, MKMapPoint(x: 0, y: factory.rect.maxY).coordinate.latitude, accuracy: 0.00001)
    }
    
    func testDivide1() {
        factory.rect.size.width = 5120
        factory.rect.size.height = 5120
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(25, factory.shots.count)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minX)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minY)
        XCTAssertEqual(1024, factory.shots.first?.options.mapRect.maxX)
        XCTAssertEqual(1024, factory.shots.first?.options.mapRect.maxY)
        XCTAssertEqual(512, factory.shots.first?.options.size.width)
        XCTAssertEqual(512, factory.shots.first?.options.size.height)
    }
    
    func testDivideMin() {
        factory.rect.origin.x = 5119
        factory.rect.origin.y = 5119
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
    }
    
    func testDivide4() {
        factory.rect.size.width = 5121
        factory.rect.size.height = 5121
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(36, factory.shots.count)
    }
    
    func testDivideCentred() {
        factory.rect.origin.x = 2559
        factory.rect.origin.y = 2559
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(2048, factory.shots.first?.options.mapRect.minX)
        XCTAssertEqual(2048, factory.shots.first?.options.mapRect.minY)
        XCTAssertEqual(3072, factory.shots.first?.options.mapRect.maxX)
        XCTAssertEqual(3072, factory.shots.first?.options.mapRect.maxY)
    }
    
    func testRegister() {
        factory.plan.path = [.init(), .init()]
        factory.plan.path[0].name = "hello"
        factory.plan.path[0].options = [.init()]
        factory.plan.path[0].options[0].duration = 1
        factory.plan.path[0].options[0].distance = 2
        factory.plan.path[1].name = "world"
        factory.plan.path[1].options = [.init()]
        factory.plan.path[1].options[0].duration = 1
        factory.plan.path[1].options[0].distance = 2
        factory.register()
        XCTAssertEqual(factory.item.id, factory.id)
        XCTAssertEqual("hello", factory.item.origin)
        XCTAssertEqual("world", factory.item.destination)
        XCTAssertEqual(2, factory.item.walking.duration)
        XCTAssertEqual(4, factory.item.walking.distance)
    }
    
    func testRegisterEmpty() {
        factory.register()
        XCTAssertEqual("", factory.item.origin)
        XCTAssertEqual("", factory.item.destination)
    }
    
    func testIsValid() {
        factory.rect = .init(x: 0, y: 0, width: 328132, height: 0)
        XCTAssertFalse(factory.valid)
        factory.rect = .init(x: 0, y: 0, width: 0, height: 328132)
        XCTAssertFalse(factory.valid)
        factory.rect = .init(x: 0, y: 0, width: 250000, height: 250000)
        XCTAssertTrue(factory.valid)
    }
}
