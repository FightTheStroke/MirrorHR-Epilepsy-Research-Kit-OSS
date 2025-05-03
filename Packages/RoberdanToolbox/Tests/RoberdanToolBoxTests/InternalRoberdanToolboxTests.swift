@testable import RoberdanToolBox
import XCTest

final class InternalRoberdanToolboxTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RoberdanToolBox().text, "(c) FightTheStroke.org")
    }
    
    func testErrorTelemetry() throws {
        let expectation = self.expectation(description: "Hitting Telemetry in the cloud")
        let done: Bool = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            expectation.fulfill()
        }
        MainDebugger.shared.append("Testing error via maindebugger", .error, sourceModule: "testErrorTelemetry")
        MainDebugger.shared.append("Testing fatal error log via mainDebugger", .fatalError, sourceModule: "Test error telemetry")
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(done, true)
    }
}

