@testable import Argonaut
import XCTest
import MapKit

final class TestFactory: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init(.init())
        factory.plan.route = [.init(.init())]
    }
    
    func testMeasure() {
        factory.plan.route[0].path = [MockRoute([(-50, 60), (70, -80), (-30, 20), (82, -40)])]
        factory.measure()
        XCTAssertEqual(-80.001, factory.rect.origin.coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(82.001, factory.rect.origin.coordinate.latitude, accuracy: 0.00001)
        XCTAssertEqual(60.001, MKMapPoint(x: factory.rect.maxX, y: 0).coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(-50.001, MKMapPoint(x: 0, y: factory.rect.maxY).coordinate.latitude, accuracy: 0.00001)
    }
    
    func testDivide1() {
        factory.rect.size.width = 5120
        factory.rect.size.height = 5120
        factory.range = [21]
        factory.divide()
        XCTAssertEqual(16, factory.shots.count)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minX)
        XCTAssertEqual(0, factory.shots.first?.options.mapRect.minY)
        XCTAssertEqual(1280, factory.shots.first?.options.mapRect.maxX)
        XCTAssertEqual(1280, factory.shots.first?.options.mapRect.maxY)
        XCTAssertEqual(1280, factory.shots.first?.options.size.width)
        XCTAssertEqual(1280, factory.shots.first?.options.size.height)
    }
    
    func testDivideMin() {
        factory.rect.origin.x = 5119
        factory.rect.origin.y = 5119
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = [21]
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
    }
    
    func testDivide4() {
        factory.rect.size.width = 5121
        factory.rect.size.height = 5121
        factory.range = [21]
        factory.divide()
        XCTAssertEqual(25, factory.shots.count)
    }
    
    func testDivideCentred() {
        factory.rect.origin.x = 2559
        factory.rect.origin.y = 2559
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = [21]
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(2304, factory.shots.first?.options.mapRect.minX)
        XCTAssertEqual(2304, factory.shots.first?.options.mapRect.minY)
        XCTAssertEqual(3584, factory.shots.first?.options.mapRect.maxX)
        XCTAssertEqual(3584, factory.shots.first?.options.mapRect.maxY)
    }
}
