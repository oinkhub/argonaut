@testable import Argonaut
import XCTest

final class TestSession: XCTestCase {
    override func setUp() {
        try? FileManager.default.removeItem(at: Session.url)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
        try? FileManager.default.removeItem(at: Session.url)
    }
    
    func testLoad() {
        let expect = expectation(description: "")
        let dateMin = Calendar.current.date(byAdding: {
            var d = DateComponents()
            d.day = 3
            return d
        } (), to: Date())!
        let dateMax = Calendar.current.date(byAdding: {
            var d = DateComponents()
            d.day = 4
            return d
        } (), to: Date())!
        DispatchQueue.global(qos: .background).async {
            Session.load {
                XCTAssertGreaterThanOrEqual($0.rating, dateMin)
                XCTAssertLessThan($0.rating, dateMax)
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRating() {
        let expect = expectation(description: "")
        let date = Date()
        let session = Session()
        session.rating = date
        session.save()
        Session.load {
            XCTAssertEqual(date, $0.rating)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testItems() {
        let expect = expectation(description: "")
        let session = Session()
        session.items = [.init()]
        session.items[0].id = "hello"
        session.save()
        Session.load {
            XCTAssertEqual("hello", $0.items[0].id)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdate() {
        let a = Session.Item()
        a.id = "lorem ipsum"
        let b = Session.Item()
        b.id = "lorem ipsum"
        let session = Session()
        session.items = [a]
        session.update(b)
        XCTAssertEqual(1, session.items.count)
        session.items = []
        session.update(b)
        XCTAssertEqual(1, session.items.count)
    }
}
