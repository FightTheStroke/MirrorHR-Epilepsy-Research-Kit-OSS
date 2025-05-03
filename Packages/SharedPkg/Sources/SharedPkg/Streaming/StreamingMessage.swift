import UIKit
import Foundation
import SwiftUI

public enum StreamingMessageType: String, Codable {
    case bpm = "BPM"
    case justAMessage = "JustAMessage"
    case start2Listen = "Start2Listen"
    case stop2Listen = "Stop2Listen"
    case event = "EventOnTheServer"
    case keyFlowThresholds = "KeyFlowThresholds"
}

public struct StreamingMessage: Identifiable, Equatable, Codable {
    public var id: UUID
    public var displayName: String = ""
    public var messageType: StreamingMessageType
    public let body: String?
    public let valueInt: Int?
    public let eventJson: String?
    public let time: Date
    
    public init(type: StreamingMessageType, displayName: String, body: String? = nil, valueInt: Int? = nil, event: Events? = nil) {
        id = UUID()
        time = Date()
        self.displayName = displayName
        self.messageType = type
        self.body = body
        self.valueInt = valueInt
        self.eventJson = event?.jsonString
    }
    
    public mutating func setDisplayName(_ name: String) {
        displayName = name
    }
    
    public func jsonString() -> String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("Can't encode StreamingMessage: \(error.localizedDescription)", .error, sourceModule: "StreamingMessage")
            return nil
        }
    }
    
    public static func loadFromJson(jsonString: String) -> StreamingMessage? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(StreamingMessage.self, from: data)
    }
}
