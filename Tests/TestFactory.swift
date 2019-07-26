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
        factory.plan.first!.path = [MockRoute([(0, 0)])]
        factory.measure()
        XCTAssertEqual(-0.02, factory.rect.minX)
        XCTAssertEqual(-0.02, factory.rect.minY)
        XCTAssertEqual(-0.02, factory.rect.origin.coordinate.longitude)
        XCTAssertEqual(-0.02, factory.rect.origin.coordinate.latitude)
    }
}
