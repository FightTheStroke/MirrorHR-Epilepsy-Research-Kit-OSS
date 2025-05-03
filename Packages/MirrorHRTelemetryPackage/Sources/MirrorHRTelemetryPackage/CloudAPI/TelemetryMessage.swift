//
//  TelemetryMessage.swift
//
//
//  Created by Roberto D’Angelo on 08/08/22.
//

import Foundation
import Alamofire
import SwiftUI

open class TelemetryMessage: Codable, Equatable {
    public var header: TelemetryHeader
    var telemetryVersion: String = "4.0"
    var eventType: String
    var event: String?
    var value: String?
    // added the below on June 12
    var toBeNotified: Bool = false
    var symptom: String?
    var localizedName: String?
    var startDate: String?
    var endDate: String?
    var notes: String?
    var soundName: String?
    var title: String?
    var body: String?
    var isCritical: Bool?
    var kidName: String?
    var kidID: String?
    var latitude: String?
    var longitude: String?
    
    public init(eventType: String, event: String? = nil, value: String? = nil, toBeNotified: Bool, notificationSupportStruct: NotificationSupportStruct?) {
        self.header = TelemetryHeader.shared
        self.eventType = eventType
        self.event = event
        self.value = value
        self.toBeNotified = toBeNotified
        self.kidID = header.userID
        self.kidName = TelemetryHeader.getUserName()
        if let notificationSupportStruct = notificationSupportStruct {
            symptom = notificationSupportStruct.symptom
            localizedName = notificationSupportStruct.localizedName
            startDate = notificationSupportStruct.startDate
            endDate = notificationSupportStruct.endDate
            notes = notificationSupportStruct.notes
            soundName = notificationSupportStruct.soundName
            title = notificationSupportStruct.title
            body = notificationSupportStruct.body
            isCritical = notificationSupportStruct.isCritical
            kidName = notificationSupportStruct.kidName
            kidID = notificationSupportStruct.kidID
            latitude = notificationSupportStruct.latitude
            longitude = notificationSupportStruct.longitude
        }
    }
    
    open func jsonString() -> String {
        self.header = TelemetryHeader.shared // doing this to secure timestamp is updated to when it's encoded
        
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "TelemetryMessage - jsonString")
            return ""
        }
    }
    
    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]

        // Campi obbligatori
        dictionary["header"] = header.toDictionary()  
        dictionary["telemetryVersion"] = telemetryVersion
        dictionary["eventType"] = eventType
        dictionary["toBeNotified"] = toBeNotified

        // Aggiungi i campi opzionali solo se hanno valore
        if let event = event {
            dictionary["event"] = event
        }
        if let value = value {
            dictionary["value"] = value
        }
        if let symptom = symptom {
            dictionary["symptom"] = symptom
        }
        if let localizedName = localizedName {
            dictionary["localizedName"] = localizedName
        }
        if let startDate = startDate {
            dictionary["startDate"] = startDate
        }
        if let endDate = endDate {
            dictionary["endDate"] = endDate
        }
        if let notes = notes {
            dictionary["notes"] = notes
        }
        if let soundName = soundName {
            dictionary["soundName"] = soundName
        }
        if let title = title {
            dictionary["title"] = title
        }
        if let body = body {
            dictionary["body"] = body
        }
        if let isCritical = isCritical {
            dictionary["isCritical"] = isCritical
        }
        if let kidName = kidName {
            dictionary["kidName"] = kidName
        }
        if let kidID = kidID {
            dictionary["kidID"] = kidID
        }
        if let latitude = latitude {
            dictionary["latitude"] = latitude
        }
        if let longitude = longitude {
            dictionary["longitude"] = longitude
        }

        return dictionary
    }

    
    
    public static func loadFromJson(jsonString: String) -> TelemetryMessage? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(TelemetryMessage.self, from: data)
    }
    
    public static func loadFromData(data: Data) -> TelemetryMessage? {
        var newResponse: TelemetryMessage?
        do {
            newResponse = try JSONDecoder().decode(TelemetryMessage.self, from: data)
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "TelemetryMessage - loadFromData")
        }
        return newResponse
    }
    
    public static func == (lhs: TelemetryMessage, rhs: TelemetryMessage) -> Bool {
        lhs.header.sessionID == rhs.header.sessionID
    }
}
