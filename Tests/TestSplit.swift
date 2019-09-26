@testable import Argonaut
import XCTest

final class TestSplit: XCTestCase {
    private var image: NSImage!
    private var shot: Factory.Shot!
    
    override func setUp() {
        image = .init()
        shot = .init()
    }
    
    func testResultOne() {
        shot.x = 0
        shot.y = 2
        shot.w = 2
        shot.h = 1
        let split = image.split(shot)
        XCTAssertEqual(1, split.count)
        XCTAssertEqual(1, split[0].x)
        XCTAssertEqual(2, split[0].y)
        XCTAssertFalse(split[0].data.isEmpty)
    }
    
    func testResultTwo() {
        shot.y = 2
        shot.w = 3
        shot.h = 1
        let split = image.split(shot)
        XCTAssertEqual(2, split.count)
        XCTAssertEqual(1, split[0].x)
        XCTAssertEqual(2, split[0].y)
        XCTAssertEqual(2, split[1].x)
        XCTAssertEqual(2, split[1].y)
        XCTAssertFalse(split[0].data.isEmpty)
        XCTAssertFalse(split[1].data.isEmpty)
    }
    
    func testInverseY() {
        shot.w = 2
        shot.h = 3
        let split = image.split(shot)
        XCTAssertEqual(3, split.count)
        XCTAssertEqual(1, split[0].x)
        XCTAssertEqual(2, split[0].y)
        XCTAssertEqual(1, split[1].x)
        XCTAssertEqual(1, split[1].y)
        XCTAssertEqual(1, split[2].x)
        XCTAssertEqual(0, split[2].y)
    }
    
    func testMargin() {
        shot.w = 2
        shot.h = 1
        let split = image.split(shot)
        XCTAssertEqual(1, split.count)
        XCTAssertEqual(1, split[0].x)
        XCTAssertEqual(0, split[0].y)
    }
}
