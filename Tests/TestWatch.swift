@testable import Argo
import XCTest

final class TestWatch: XCTestCase {
    private var factory: Factory!
    
    override func setUp() {
        try! FileManager.default.createDirectory(at: Argonaut.url, withIntermediateDirectories: true)
        factory = .init()
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: Argonaut.url)
        try? FileManager.default.removeItem(at: Argonaut.temporal)
    }
    
    func testShare() {
        let expect = expectation(description: "")
        factory.path = [.init(), .init()]
        factory.path[0].name = "hello"
        factory.path[0].latitude = 1
        factory.path[0].longitude = 2
        factory.path[1].name = "adasdsadas dadskjnaslkdas sakmdasklmdas asmdkaslmdlksama sdksamdklasmklsa asdsaasd\n sdadas"
        factory.path[1].latitude = 3
        factory.path[1].longitude = 4
        Argonaut.save(factory)
        Argonaut.watch(factory.item) {
            let watch = try! JSONDecoder().decode([Pointer].self, from: $0)
            XCTAssertEqual(self.factory.path[0].name, watch[0].name)
            XCTAssertEqual(1, watch[0].latitude)
            XCTAssertEqual(2, watch[0].longitude)
            XCTAssertEqual(self.factory.path[1].name, watch[1].name)
            XCTAssertEqual(3, watch[1].latitude)
            XCTAssertEqual(4, watch[1].longitude)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
