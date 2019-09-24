@testable import Argonaut
import XCTest
import MapKit

final class TestDivide: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        factory = .init()
    }
    
    func testMin() {
        factory.rect.origin.x = 5119
        factory.rect.origin.y = 5119
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
    }
    
    func testCentred() {
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
    
    func testWidthByMax() {
        factory.rect.size.width = MKMapRect.world.width / 32
        factory.rect.size.height = MKMapRect.world.width / 256
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(8, factory.shots[0].w)
        XCTAssertEqual(1, factory.shots[0].h)
        XCTAssertEqual(MKMapRect.world.width / 32, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 256, factory.shots[0].options.mapRect.height)
    }
    
    func testHeightByMax() {
        factory.rect.size.width = MKMapRect.world.width / 256
        factory.rect.size.height = MKMapRect.world.width / 32
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(1, factory.shots[0].w)
        XCTAssertEqual(8, factory.shots[0].h)
        XCTAssertEqual(MKMapRect.world.width / 256, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 32, factory.shots[0].options.mapRect.height)
    }
    
    func testWidthByLimit() {
        factory.rect.size.width = MKMapRect.world.width / 16
        factory.rect.size.height = MKMapRect.world.width / 256
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(2, factory.shots.count)
        XCTAssertEqual(10, factory.shots[0].w)
        XCTAssertEqual(1, factory.shots[0].h)
        XCTAssertEqual(6, factory.shots[1].w)
        XCTAssertEqual(1, factory.shots[1].h)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 10, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 256, factory.shots[0].options.mapRect.height)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 6, factory.shots[1].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 256, factory.shots[1].options.mapRect.height)
    }
    
    func testBothByLimit() {
        factory.rect.size.width = MKMapRect.world.width / 16 / 16 * 11
        factory.rect.size.height = MKMapRect.world.width / 8 / 32 * 21
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(6, factory.shots.count)
        XCTAssertEqual(10, factory.shots[0].w)
        XCTAssertEqual(10, factory.shots[0].h)
        XCTAssertEqual(10, factory.shots[1].w)
        XCTAssertEqual(10, factory.shots[1].h)
        XCTAssertEqual(10, factory.shots[2].w)
        XCTAssertEqual(1, factory.shots[2].h)
        XCTAssertEqual(1, factory.shots[3].w)
        XCTAssertEqual(10, factory.shots[3].h)
        XCTAssertEqual(1, factory.shots[4].w)
        XCTAssertEqual(10, factory.shots[4].h)
        XCTAssertEqual(1, factory.shots[5].w)
        XCTAssertEqual(1, factory.shots[5].h)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 10, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 10, factory.shots[0].options.mapRect.height)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16, factory.shots[5].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16, factory.shots[5].options.mapRect.height)
    }
    
    func testFlightOne() {
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (1 ... 1)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(2, factory.shots[0].w)
        XCTAssertEqual(2, factory.shots[0].h)
        XCTAssertEqual(0, factory.shots[0].options.mapRect.minX)
        XCTAssertEqual(0, factory.shots[0].options.mapRect.minY)
        XCTAssertEqual(MKMapRect.world.width, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width, factory.shots[0].options.mapRect.height)
    }
}
