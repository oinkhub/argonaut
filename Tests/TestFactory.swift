@testable import Argonaut
import XCTest
import MapKit

final class TestFactory: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = Factory()
        factory.plan = [Route(.init())]
    }
    
    func testMeasure() {
        factory.plan.first!.path = [MockRoute([(-50, 60), (70, -80), (-30, 20), (82, -40)])]
        factory.measure()
        XCTAssertEqual(-80.01, factory.rect.origin.coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(-50.01, factory.rect.origin.coordinate.latitude, accuracy: 0.00001)
        XCTAssertEqual(60.01, MKMapPoint(x: factory.rect.maxX, y: 0).coordinate.longitude, accuracy: 0.00001)
        XCTAssertEqual(82.01, MKMapPoint(x: 0, y: factory.rect.maxY).coordinate.latitude, accuracy: 0.00001)
    }
    
    func testDivide1() {
        factory.rect.size.width = 5120
        factory.rect.size.height = 5120
        factory.range = (21 ... 21)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(0, factory.shots.first?.mapRect.minX)
        XCTAssertEqual(0, factory.shots.first?.mapRect.minY)
        XCTAssertEqual(5120, factory.shots.first?.mapRect.maxX)
        XCTAssertEqual(5120, factory.shots.first?.mapRect.maxY)
        XCTAssertEqual(5120, factory.shots.first?.size.width)
        XCTAssertEqual(5120, factory.shots.first?.size.height)
    }
    
    func testDivideMin() {
        factory.rect.origin.x = 5119
        factory.rect.origin.y = 5119
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (21 ... 21)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
    }
    
    func testDivide4() {
        factory.rect.size.width = 5121
        factory.rect.size.height = 5121
        factory.range = (21 ... 21)
        factory.divide()
        XCTAssertEqual(4, factory.shots.count)
    }
    
    func testDivideCentred() {
        factory.rect.origin.x = 2559
        factory.rect.origin.y = 2559
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (21 ... 21)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(0, factory.shots.first?.mapRect.minX)
        XCTAssertEqual(0, factory.shots.first?.mapRect.minY)
        XCTAssertEqual(5120, factory.shots.first?.mapRect.maxX)
        XCTAssertEqual(5120, factory.shots.first?.mapRect.maxY)
    }
}
