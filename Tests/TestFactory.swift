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
}
