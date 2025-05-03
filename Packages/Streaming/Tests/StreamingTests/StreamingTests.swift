import XCTest
@testable import Streaming
@testable import SharedPkg

final class StreamingTests: XCTestCase {
    func testMirrorHRErrorsCodable() throws {
        print ("errori da testare: \(WatchCommunicationErrors.testSamples.count)")
        var cnt: Int = 0
        WatchCommunicationErrors.testSamples.forEach { mirrorHRError in
            cnt += 1
            print ("Error number \(cnt): " + String(describing: mirrorHRError))
            let errorJson: String = mirrorHRError.jsonString ?? "empty jsonString"
            print("Error JSON: " + errorJson)
            let backError: WatchCommunicationErrors? = WatchCommunicationErrors.loadFromJson(jsonString: errorJson) ?? nil
            print("BACK Error: " + String(describing: backError))
            if mirrorHRError != backError {
                print ("ERRORE: \(mirrorHRError.debugDescription) NON E' UGUALE a \(backError?.debugDescription ?? "backError è NIL")")
                print ("DETTAGLIO ERRORE per \(mirrorHRError.debugDescription): event json: \(mirrorHRError.jsonString ?? "NIL") e backError Json: \(backError?.jsonString ?? "NIL")")
            } else {
                print("SUCCESS: \(mirrorHRError.debugDescription) UGUALE e \(backError?.debugDescription ?? "NIL")")
            }
            XCTAssertEqual(mirrorHRError, backError)
        }
    }
    
    func testEventsCodable() throws {
        print("eventi da testare: \(Events.testEvents.count)")
        var cnt: Int = 0
        Events.testEvents.forEach { event in
            cnt += 1
            print("EVENT number \(cnt): " + String(describing: event))
            let eventJson: String = event.jsonString ?? "empty eventjson"
            print("EVENT JSON: " + eventJson)
            let backEvent: Events? = Events.loadFromJson(jsonString: eventJson) ?? nil
            print("BACK EVENT: " + String(describing: backEvent))
            if event != backEvent {
                print ("ERRORE: \(event.debugDescription) NON E' UGUALE a \(backEvent?.debugDescription ?? "backEvent è NIL")")
                print ("DETTAGLIO ERRORE per \(event.debugDescription): event json: \(event.jsonString ?? "NIL") e backEvent Json: \(backEvent?.jsonString ?? "NIL")")
            } else {
                print("SUCCESS: \(event.debugDescription) UGUALE e \(backEvent?.debugDescription ?? "NIL")")
            }
            XCTAssertEqual(event, backEvent)
        }
    }
}
