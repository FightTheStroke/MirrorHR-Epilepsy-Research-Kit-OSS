import XCTest
@testable import OpenAIPackage

@available(iOS 14.0, *)
class OpenAIConnectorTests: XCTestCase {
    
    var connector: OpenAIConnector!
    
    override func setUp() {
        super.setUp()
        connector = OpenAIConnector.shared
        // Here, if OpenAIConnector accepted a URLSession in init, you could inject mockSession
    }
    
    override func tearDown() {
        connector = nil
        super.tearDown()
    }
    
    func testProcessPrompt() {
        let prompt = "Hello, OpenAI, that's a test: if you are there just reply with 'Hello, I am here.'"
        
        let expectedText = "\n\nHello, I am here."
        
        let result = connector.processPrompt(prompt: prompt)
        XCTAssertEqual(result, expectedText)
    }
    
    func testProcessPrompt2() {
        let preProcess = "Give me back an array of suggested reminders from the following sentence as day, time, medication for each day of the week: "
        let prompt = "Remember me to take 3 pills of Tegretol and 3 pills of Topamax every weekday in the morning at 7.30am and in the evening at 9.15pm. And on the week end it's ok if I take it in the morning at 9am and in the evening at 9pm"
        
        let expectedText = "\n\nHello, I am here."
        
        let result = connector.processPrompt(prompt: preProcess + "" + prompt)
        print(result as Any)
        XCTAssertNotNil(result)
    }
    
    // Add more tests as needed
}
