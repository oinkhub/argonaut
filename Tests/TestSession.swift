@testable import Argonaut
import XCTest

final class TestSession: XCTestCase {
    override func setUp() {
        UserDefaults.standard.removeObject(forKey: "session")
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
        Session.load {
            XCTAssertEqual("hello", $0.items[0].id)
            expect.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
