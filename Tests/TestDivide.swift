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
        factory.rect.origin.x = MKMapRect.world.width / 2
        factory.rect.origin.y = MKMapRect.world.width / 2
        factory.rect.size.width = 1
        factory.rect.size.height = 1
        factory.range = (18 ... 18)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(134214656.0, factory.shots[0].options.mapRect.minX)
        XCTAssertEqual(134215680.0, factory.shots[0].options.mapRect.minY)
        XCTAssertEqual(134220800.0, factory.shots[0].options.mapRect.maxX)
        XCTAssertEqual(134220800.0, factory.shots[0].options.mapRect.maxY)
        XCTAssertEqual(.init(Argonaut.tile), factory.shots[0].options.size.width / 6)
        XCTAssertEqual(.init(Argonaut.tile), factory.shots[0].options.size.height / 5)
    }
    
    func testWidthByMax() {
        factory.rect.size.width = MKMapRect.world.width / 32 / 8 * 3
        factory.rect.size.height = MKMapRect.world.width / 256
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(8, factory.shots[0].w)
        XCTAssertEqual(5, factory.shots[0].h)
        XCTAssertEqual(MKMapRect.world.width / 32 / 8 * 8, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 256 * 5, factory.shots[0].options.mapRect.height)
        XCTAssertEqual(.init(Argonaut.tile) * 8, factory.shots[0].options.size.width)
        XCTAssertEqual(.init(Argonaut.tile) * 5, factory.shots[0].options.size.height)
    }
    
    func testHeightByMax() {
        factory.rect.size.width = MKMapRect.world.width / 256
        factory.rect.size.height = MKMapRect.world.width / 32 / 8 * 3
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(1, factory.shots.count)
        XCTAssertEqual(6, factory.shots[0].w)
        XCTAssertEqual(7, factory.shots[0].h)
        XCTAssertEqual(MKMapRect.world.width / 256 * 6, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 32 / 8 * 7, factory.shots[0].options.mapRect.height)
        XCTAssertEqual(.init(Argonaut.tile) * 6, factory.shots[0].options.size.width)
        XCTAssertEqual(.init(Argonaut.tile) * 7, factory.shots[0].options.size.height)
    }
    
    func testWidthByLimit() {
        factory.rect.size.width = MKMapRect.world.width / 8 / 32 * 31
        factory.rect.size.height = MKMapRect.world.width / 256
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(4, factory.shots.count)
        XCTAssertEqual(10, factory.shots[0].w)
        XCTAssertEqual(5, factory.shots[0].h)
        XCTAssertEqual(10, factory.shots[1].w)
        XCTAssertEqual(5, factory.shots[1].h)
        XCTAssertEqual(10, factory.shots[2].w)
        XCTAssertEqual(5, factory.shots[2].h)
        XCTAssertEqual(9, factory.shots[3].w)
        XCTAssertEqual(5, factory.shots[3].h)
        XCTAssertEqual(MKMapRect.world.width / 8 / 32 * 10, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 256 * 5, factory.shots[0].options.mapRect.height)
        XCTAssertEqual(MKMapRect.world.width / 8 / 32 * 9, factory.shots[3].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 256 * 5, factory.shots[1].options.mapRect.height)
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
        XCTAssertEqual(5, factory.shots[2].h)
        XCTAssertEqual(7, factory.shots[3].w)
        XCTAssertEqual(10, factory.shots[3].h)
        XCTAssertEqual(7, factory.shots[4].w)
        XCTAssertEqual(10, factory.shots[4].h)
        XCTAssertEqual(7, factory.shots[5].w)
        XCTAssertEqual(5, factory.shots[5].h)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 10, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 10, factory.shots[0].options.mapRect.height)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 7, factory.shots[5].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 16 / 16 * 5, factory.shots[5].options.mapRect.height)
    }
    
    func testFlightMin() {
        factory.range = (2 ... 2)
        factory.divide()
        XCTAssertEqual(8, factory.shots.count)
        XCTAssertEqual(2, factory.shots[0].w)
        XCTAssertEqual(2, factory.shots[0].h)
        XCTAssertEqual(MKMapRect.world.width / -4, factory.shots[0].options.mapRect.minX)
        XCTAssertEqual(0, factory.shots[0].options.mapRect.minY)
        XCTAssertEqual(MKMapRect.world.width / 2, factory.shots[0].options.mapRect.width)
        XCTAssertEqual(MKMapRect.world.width / 2, factory.shots[0].options.mapRect.height)
    }
    
    func testMargin() {
        factory.rect.origin.x = MKMapRect.world.width / 32 / 8 * 5
        factory.rect.origin.y = MKMapRect.world.width / 32 / 8 * 5
        factory.rect.size.width = MKMapRect.world.width / 32 / 8
        factory.rect.size.height = MKMapRect.world.width / 32 / 8
        factory.range = (8 ... 8)
        factory.divide()
        XCTAssertEqual(6, factory.shots[0].w)
        XCTAssertEqual(5, factory.shots[0].h)
        XCTAssertEqual(2, factory.shots[0].x)
        XCTAssertEqual(3, factory.shots[0].y)
    }
    
    func testMarginFlightMin() {
        factory.range = (2 ... 2)
        factory.divide()
        XCTAssertEqual(-1, factory.shots[0].x)
        XCTAssertEqual(0, factory.shots[0].y)
        XCTAssertEqual(2, factory.shots[0].w)
        XCTAssertEqual(2, factory.shots[0].h)
        
        XCTAssertEqual(2, factory.shots[7].x)
        XCTAssertEqual(2, factory.shots[7].y)
        XCTAssertEqual(2, factory.shots[7].w)
        XCTAssertEqual(2, factory.shots[7].h)
    }
}
