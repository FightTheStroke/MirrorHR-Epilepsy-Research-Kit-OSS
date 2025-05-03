//
//  TelemetryEnginesEnum.swift
//  
//
//  Created by Roberto D’Angelo on 08/08/22.
//

import Foundation
import OSLog

public struct Consensus: Equatable, Hashable, Identifiable {
    public var id: UUID = UUID()
    public let telemetry: Telemetries
    public var isOn: Bool {
        didSet {
            isOn ? telemetry.turnOn() : telemetry.turnOff()
        }
    }
}

public class TelemetryConsensus: ObservableObject {
    static public let shared: TelemetryConsensus = TelemetryConsensus()
    @Published public var telemetries: [Consensus] = []
    @Published public var researchID: String = TelemetryHeader.shared.researchID
    
    internal init() {
        Telemetries.allCases.forEach { telemetry in
            telemetries.append(Consensus(telemetry: telemetry, isOn: telemetry.isOn))
        }
    }
    
    public func saveResearchID() {
        DispatchQueue.main.async { [self] in
                if TelemetryHeader.shared.researchID != researchID {
                TelemetryHeader.shared.researchID = researchID
            }
        }
    }
    
    public func isOn(type: Telemetries) -> Bool {
        guard let telemetry = telemetries.first(where: { $0.telemetry.eventType == type.eventType }) else {
            return Telemetries.defaultValue
        }
        return telemetry.isOn ? true : false
    }
}

public enum TelemetryEngines: CaseIterable {
    case telemetryDeck
    case researchCloudApi
}

public enum UserType: String, Codable {
    case unknown = "Unknown User Type"
    case brandNewUser = "Brand new user"
    case updatingUser = "Updating user"
    case returningUser = "Returning user"
}

public enum Telemetries: CaseIterable, Hashable {
    case symptomsLogged(notificationSupportStruct: NotificationSupportStruct)
    case medicationReminders(recurrence: String)
    case checkList(type: String, value: String)
    case dateOfBirth(birthDate: String)
    case epilepsyType(type: String)
    case mirrorHRError(sourceModule: String, error: String)
    case realTimeTelemetrySession(jsonString: String)
    case customAnalytics(type: String, value: String)
    case booting(userType: UserType, value: String)
    case consensus(telemetry: String, newValue: Bool)
    case streaming(status: String)
    case notificationHub(hubName: String, tags: [String])
    case newCareGiver(name: String, uuid: String)
    case valueChanged(valueName: String, newValue: String)
    case remoteBPM(remoteBPM: RemoteBPM)
    case remoteCommand(command: RemoteCommand)
    
    public static var allCases: [Telemetries] = [
        .symptomsLogged(notificationSupportStruct: NotificationSupportStruct()),
        .medicationReminders(recurrence: ""),
        .realTimeTelemetrySession(jsonString: ""),
        .dateOfBirth(birthDate: Date().toDayMonthYear()),
        .epilepsyType(type: ""),
    ]
    
    public static var canShareRealtimeSession: Bool {
        return Telemetries.realTimeTelemetrySession(jsonString: "").isOn
    }
    
    public static let defaultValue: Bool = true
    
    public var eventType: String {
        switch self {
        case .booting:
            return "Booting"
        case .symptomsLogged:
            return "SymptomsLogged"
        case .medicationReminders:
            return "MedicationReminders"
        case .checkList:
            return "CheckList"
        case .dateOfBirth:
            return "DateOfBirth"
        case .epilepsyType:
            return "EpilepsyType"
        case .mirrorHRError:
            return "MirrorHRError"
        case .realTimeTelemetrySession:
            return "MonitoringSession"
        case .customAnalytics:
            return "CustomAnalytics"
        case .consensus:
            return "Consensus"
        case .streaming:
            return "Streaming"
        case .notificationHub:
            return "NotificationHub"
        case .newCareGiver:
            return "NewCaregiverForRemoteNotifications"
        case .valueChanged:
            return "ValueChanged"
        case .remoteBPM:
            return "RemoteBPM"
        case .remoteCommand:
            return "RemoteCommand"
        }
    }
    
    var event: String {
        switch self {
        case .booting(let userType, _):
            return userType.rawValue
        case .symptomsLogged(let notificationSupportStruct):
            return notificationSupportStruct.symptom
        case .medicationReminders:
            return "Reminder"
        case .checkList(let type, _):
            return type
        case .dateOfBirth:
            return "Date"
        case .epilepsyType:
            return "Type"
        case .mirrorHRError(let sourceModule, _):
            return sourceModule
        case .realTimeTelemetrySession:
            return "MonitoringSession"
        case .customAnalytics(let type, _):
            return type
        case .streaming:
            return "StreamingStatus"
        case .consensus(let telemetry, _):
            return telemetry
        case .notificationHub:
            return "NotificationHub"
        case .newCareGiver:
            return "NewCaregiverForRemoteNotifications"
        case .valueChanged(let valueName, _):
            return "Value changed: \(valueName)"
        case .remoteBPM:
            return "RemoteBPM"
        case .remoteCommand(let remoteCommand):
            return remoteCommand.command.rawValue
        }
    }
    
    var value: String {
        switch self {
        case .medicationReminders(let value):
            return value
        case .checkList(_, let value):
            return value
        case .dateOfBirth(let value):
            return value
        case .epilepsyType(let value):
            return value
        case .mirrorHRError(_, let value):
            return value
        case .realTimeTelemetrySession(let jsonString):
            return jsonString
        case .customAnalytics(_, let value):
            return value
        case .booting(_, let value):
            return value
        case .consensus(_, let newValue):
            return "\(newValue)"
        case .streaming(let status):
            return "\(status)"
        case .notificationHub(hubName: let hubName, tags: let tags):
            var returnValueArray: [String] = tags
            returnValueArray.append("hubName_\(hubName)")
            return returnValueArray.joined(separator: ",")
        case .newCareGiver(name: let name, uuid: let uuid):
            return name + "=" + uuid
        case .symptomsLogged(let notificationSupportStruct):
            return notificationSupportStruct.notes
        case .valueChanged(_, newValue: let newValue):
            return "\(newValue)"
        case .remoteBPM(let remoteBPM):
            return remoteBPM.jsonString
        case .remoteCommand(let command):
            return command.jsonString
        }
    }
    
    var remoteCommandFromCareGiverToKid: RemoteCommand? {
        switch self {
        case .remoteCommand(let command): return command
        default: return nil
        }
    }
    
    var notificationSupportStruct: NotificationSupportStruct? {
        switch self {
        case .symptomsLogged(let notificationSupportStruct):
            return notificationSupportStruct
        default: return nil
        }
    }
    
    public var description: String {
        return NSLocalizedString("TelemetryLocalized\(self.eventType)", comment: "localized telemetry event")
    }
    
    public var debugDescription: String {
        return "\(self.event) - \(self.value)"
    }
    
    
    public func turnOn() {
        UserDefaults.standard.setValue(true, forKey: self.eventType)
        dispatchTelemetryEvent(event: .consensus(telemetry: self.eventType, newValue: true))
    }
    
    public func turnOff() {
        UserDefaults.standard.setValue(false, forKey: self.eventType)
        dispatchTelemetryEvent(event: .consensus(telemetry: self.eventType, newValue: false))
    }
}

extension Telemetries {
    public static func turnAllOn() {
        Telemetries.allCases.forEach { type in
            type.turnOn()
        }
    }
    
    public static func turnAllOff() {
        Telemetries.allCases.forEach { type in
            type.turnOff()
        }
    }
    
    public static var areAllOn: Bool {
        return Telemetries.allCases.allSatisfy { telemetryType in
            telemetryType.isOn
        }
    }
    
    public static var howManyAreOn: Int {
        return Telemetries.allCases.filter { type in
            type.isOn
        }.count
    }
    
    public static var partiallyOn: Bool {
        return howManyAreOn > 0
    }
    
    public var isOn: Bool {
        guard let state = UserDefaults.isTelemetryOn(for: self.eventType) else {
            return defaultValueForTelemetry()
        }
        return state
    }
    
    private func defaultValueForTelemetry() -> Bool {
        if Telemetries.defaultValue {
            turnOn()
        } else {
            turnOff()
        }
        return Telemetries.defaultValue
    }
}
   
public enum RemoteCommands: String, Codable {
    case startSteamingToCareGiver
    case stopStreamingToCareGiver
    case careGiverCheckingRealTimeStatus
    case patientReplyRealTimeStatusIsOn
    case patientReplyRealTimeStatusIsOff
    case patientStartedRealTimeSession
    case patientStoppedRealTimeSession
    case careGiverCheckingWhereAreYou
    case patientReplyHereIam
}

public struct RemoteCommand: Codable, Hashable {
    public let command: RemoteCommands
    public let careGiverName: String
    public let careGiverID: String
    public let kidID: String
    public let kidName: String
    public let latitude: String
    public let longitude: String
    
    public init(command: RemoteCommands, careGiverName: String, careGiverID: String, kidID: String, kidName: String) {
        let locationManager: LocationManager = .shared
        self.command = command
        self.careGiverName = careGiverName
        self.careGiverID = careGiverID
        self.kidID = kidID
        self.kidName = kidName
        self.latitude = locationManager.currentLatitude
        self.longitude = locationManager.currentLongitude
    }
    
    public var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            print("can't encode jsonstring for RemoteCommandFromCareGiverToKid")
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> RemoteCommand? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(RemoteCommand.self, from: data)
    }
}

public struct RemoteBPM: Codable, Hashable {
    public let bpmValue: Int
    public let timeStamp: String
    public let kidName: String
    public let kidID: String
    
    public init(bpmValue: Int, date: Date) {
        self.bpmValue = bpmValue
        self.timeStamp = date.toStdString()
        self.kidID = TelemetryHeader.getUserID()
        self.kidName = TelemetryHeader.getUserName()
    }
    
    var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            print("can't encode jsonstring for AlarmValue")
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> RemoteBPM? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(RemoteBPM.self, from: data)
    }
}



public struct NotificationSupportStruct: Codable, Hashable {
    public let kidName: String
    public let kidID: String
    public let symptom: String
    public let localizedName: String
    public let startDate: String
    public let endDate: String
    public let notes: String
    public let soundName: String
    public let title: String
    public let body: String
    public let isCritical: Bool
    public var latitude: String?
    public var longitude: String?
    
    public init() {
        self.kidName = "unknown"
        self.kidID = "unknown"
        self.symptom = "symptom"
        self.localizedName = "localizedName"
        self.startDate = "startDate.toStdString()"
        self.endDate = "endDate.toStdString()"
        self.notes = "notes"
        self.soundName = "soundName"
        self.title = "title"
        self.body = "body"
        self.isCritical = false
        self.latitude = nil
        self.longitude = nil
    }
    
    public init(kidName: String, kidID: String, symptom: String, localizedName: String, startDate: Date, endDate: Date, notes: String, soundName: String, title: String, body: String, isCritical: Bool, latitude: String?, longitude: String?) {
        self.kidName = kidName
        self.kidID = kidID
        self.symptom = symptom
        self.localizedName = localizedName
        self.startDate = startDate.toStdString()
        self.endDate = endDate.toStdString()
        self.soundName = soundName
        self.title = title
        self.body = body
        self.isCritical = isCritical
        self.notes = Self.normalizeNotes(notes) // Normalize notes before assigning
        
        if let latitude = latitude, let longitude = longitude {
            self.latitude = latitude
            self.longitude = longitude
        } else {
            self.latitude = LocationManager.shared.currentLatitude
            self.longitude = LocationManager.shared.currentLongitude
        }
    }
    
    var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            print("can't encode jsonstring for AlarmValue")
            return ""
        }
    }
    
    // Normalize notes by removing newlines, commas, and any problematic characters
    private static func normalizeNotes(_ notes: String) -> String {
        var normalizedNotes = notes.replacingOccurrences(of: "\n", with: " ") // Replace newlines with spaces
        normalizedNotes = normalizedNotes.replacingOccurrences(of: ",", with: " ") // Replace commas with spaces
        normalizedNotes = normalizedNotes.replacingOccurrences(of: "\"", with: "'") // Replace double quotes with single quotes
        return normalizedNotes
    }
}
