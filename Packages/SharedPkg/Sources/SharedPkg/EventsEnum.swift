//
//  EventsEnum.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 03/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
#if os(iOS)
    import RoberdanToolBox
#endif

/// Represents all system events that can occur within the MirrorHR application
///
/// The Events enum provides a centralized definition of all possible events
/// that can occur during application operation. This enables consistent
/// event handling and dispatching throughout the application. Most events
/// include metadata that provides context about when and where the event occurred.
///
/// Events are used for communication between app components, alarm management,
/// error handling, and system state notification.
public enum Events: Equatable, Codable {
    /// Generated when heart rate exceeds alarm thresholds and stays there
    /// for duration specified in KeyFlowThresholds
    case alarm(metaData: EventMetaData)
    
    /// Generated when user manually triggers an alarm through the UI
    case manualAlarm(metaData: EventMetaData)
    
    /// Generated when heart rate enters warning zones (approaching alarm thresholds)
    case warning(metaData: EventMetaData)
    
    /// Generated when no heart rate data is received from local device
    /// for longer than maxIntervalWithoutData
    case noLocalData(metaData: EventMetaData)
    
    /// Generated when no heart rate data is received from remote streaming device
    /// for longer than maxIntervalWithoutData
    case noStreamingData(metaData: EventMetaData)
    
    /// Generated when a new heart rate value is received from any source
    case lastBPM(_ bpm: Int, metaData: EventMetaData)
    
    /// Generated when Apple Watch battery level falls below threshold
    case lowBatteryWatch(metaData: EventMetaData)
    
    /// Generated when iPhone battery level falls below threshold
    case lowBatteryIphone(metaData: EventMetaData)
    
    /// Generated for events that don't fit other categories
    case unclassifiedEvent(metaData: EventMetaData)
    
    /// Generated when user confirms a seizure event in response to an alarm
    case handleSeizure(metaData: EventMetaData)
    
    /// Generated when user indicates an alarm was a false positive
    case handleFalseAlarm(firingBPM: Int, notes: String)
    
    /// Generated when monitoring is stopped from the Apple Watch
    case stopReceivedFromWatch
    
    /// Generated when monitoring is stopped from the iPhone
    case stopFromIphone
    
    /// Generated when monitoring is stopped from a remote streaming source
    case stopFromRemoteStreaming
    
    /// Generated when a critical error occurs that requires user attention
    case criticalError(errorMessage: String)
    
    /// Generated to test alarm sounds with optional delay and criticality
    case testSound(critical: Bool, delay: TimeInterval)
    
    /// Generated when a new monitoring session begins
    case sessionBoot
    
    /// Generated when it's time for scheduled medication
    case medicationAlert
    
    /// Generated when a medication alert is snoozed
    case medicationSnooze
    
    /// Generated when the application is about to terminate
    case termination
    
    /// Generated when user acknowledges streaming alert
    case streamingUnderstandAlert
    
    /// Generated when the active patient profile is changed
    case activePatientChanged
    
    /// Generated when a notification couldn't be delivered
    case cantFireNotification(errorMessage: String)
    
    /// Generated when there's an error with HealthKit authorization
    case HealthAuthorizationError(errorMessage: String)
    
    /// Generated when the Apple Watch is not reachable by the iPhone
    case watchNotReachable

    /// Human-readable description of the event
    /// 
    /// Used for debugging, logging, and UI display purposes
    public var debugDescription: String {
        switch self {
        case .medicationAlert:
            return "Medication Alert"
        case .medicationSnooze:
            return "Medication Snooze"
        case .alarm:
            return "Alarm"
        case .warning:
            return "Warning"
        case .noLocalData:
            return noDataEventStringV2
        case .lowBatteryWatch:
            return "Low battery on Apple Watch"
        case .lowBatteryIphone:
            return "Low battery on iPhone"
        case .unclassifiedEvent:
            return "Unclassified event"
        case .handleSeizure:
            return "Handle seizure"
        case .handleFalseAlarm:
            return "Handle false alarm"
        case .stopReceivedFromWatch:
            return "Strom received from Watch"
        case .stopFromIphone:
            return "Stop received from iPhone"
        case .criticalError(let errorMessage):
            return "Critical Error:" + errorMessage
        case .testSound(critical: let critical, delay: _):
            return "Test sound" + "\(critical ? "alarm" : "notification")"
        case .sessionBoot:
            return "Session booting"
        case .manualAlarm:
            return "Manual Alarm"
        case .lastBPM:
            return "Last BPM"
        case .termination:
            return "MirrorHR terminated"
        case .streamingUnderstandAlert:
            return "Checking Streaming Understand"
        case .activePatientChanged:
            return "Active patient has changed" // no localized version needed as it's not going to show
        case let .cantFireNotification(errorMessage): return "canTFireNotificationString" + "\(errorMessage)"
        case .HealthAuthorizationError(let errorMessage):
            return errorMessage
        case .watchNotReachable:
            return "Watch Not Reachable"
        case .stopFromRemoteStreaming:
            return "Stop received from remote child"
        case .noStreamingData:
            return "No Data received from the Internet Streaming"
        }
    }
    
    public var description: String {
        switch self {
        case .medicationAlert:
            return medicationAlarmString
        case .medicationSnooze:
            return medicationSnoozeStringDescription
        case .alarm:
            return alarmEventString
        case .warning:
            return warningEventString
        case .noLocalData:
            return "NoDataEventStringV2".local()
        case .lowBatteryWatch:
            return "Apple Watch " + lowBatteryEventString
        case .lowBatteryIphone:
            return "iPhone " + lowBatteryEventString
        case .unclassifiedEvent:
            return unclassifiedEventString
        case .handleSeizure:
            return handleSeizureEventString
        case .handleFalseAlarm:
            return handleFalseAlarmEventString
        case .stopReceivedFromWatch:
            return stopFromWatchEventString
        case .stopFromIphone:
            return sessionStopFromPhoneEventString
        case let .criticalError(errorMessage: errorMessage):
            return criticalErrorEventString + errorMessage
        case .testSound(critical: let critical, delay: _):
            return testSoundEventString + "\(critical ? alarmMsg : notificationString)"
        case .sessionBoot:
            return sessionBootingEventString
        case .manualAlarm:
            return manualAlarmEventString
        case .lastBPM:
            return lastBpmMsg
        case .termination:
            return "appTerminatedMessage".local()
        case .streamingUnderstandAlert:
            return "CheckStreamingUnderstandAlert".local()
        case .activePatientChanged:
            return "Join to a stream has been cancelled" // no localized version needed as it's not going to show
        case let .cantFireNotification(errorMessage: errorMessage): return (canTFireNotificationString + errorMessage)
        case .HealthAuthorizationError(let errorMessage):
            return errorMessage.local()
        case .watchNotReachable:
            return watchNotReachableString
        case .stopFromRemoteStreaming:
            return "RemoteStopReceivedFromPatientMsg".local()
        case .noStreamingData:
            return "RemoteNoDataFromTheInternetMsg".local()
        }
    }
    
    public var notificationTitle: String {
        switch self {
        case .medicationAlert:
            return medicationAlarmString
        case .medicationSnooze:
            return medicationSnoozeStringDescription
        case .alarm:
            return alarmEventString
        case .warning, .noLocalData, .unclassifiedEvent, .stopReceivedFromWatch, .stopFromIphone, .stopFromRemoteStreaming, .testSound, .sessionBoot, .cantFireNotification, .activePatientChanged, .streamingUnderstandAlert, .termination, .watchNotReachable:
            return warningEventString
        case .lowBatteryWatch:
            return lowBatteryEventString
        case .lowBatteryIphone:
            return lowBatteryEventString
        case .handleSeizure:
            return handleSeizureEventString
        case .handleFalseAlarm:
            return handleFalseAlarmEventString
        case .criticalError, .HealthAuthorizationError:
            return criticalErrorEventString
        case .manualAlarm:
            return manualAlarmEventString
        case .lastBPM:
            return lastBpmMsg
        case .noStreamingData:
            return warningEventString
        }
    }

    public var notificationBody: String {
        var returnString: String = ""
        switch self {
        case .medicationAlert:
            returnString = medicationNotificationBodyMessage
        case .medicationSnooze:
            return medicationNotificationBodyMessage
        case .noLocalData(let metaData):
            let noDataFor = metaData.valueInt ?? 0
            returnString = "NoDataReceivedStringV2".local() + " \(noDataFor) " + "secondsString".local() + checkRangeString
        case .noStreamingData(let metaData):
            let noDataFor = metaData.valueInt ?? 0
            returnString = "RemoteNoDataFromTheInternetMsg".local() + " \(noDataFor) " + "secondsString".local() + checkRangeString
        case let .criticalError(errorMessage: errorMessage):
            returnString = errorMessage
        case .alarm(let metaData):
            var bpmString: String = "Unknown"
            if let bpm: Int = metaData.valueInt {
                bpmString = "\(bpm)"
            }
            returnString = alarmFiredAtString + "\(Date().toShort()) " + byBPMofMsg + " \(bpmString)"
        default:
            returnString = description
        }
        
        return returnString + " " + "TapHereToHandleMsg".local()
    }

    public var notificationSound: String {
        switch self {
        case .alarm:
            return SoundOptions.shared.alarmSound
        case .medicationAlert, .medicationSnooze:
            return SoundOptions.shared.medicationReminderSound
        case .testSound(critical: true, _):
            return SoundOptions.shared.alarmSound
        case .testSound(critical: false, _):
            return SoundOptions.shared.notificationSound
        case .manualAlarm,
             .warning,
             .noLocalData,
             .lowBatteryWatch,
             .lowBatteryIphone,
             .unclassifiedEvent,
             .handleSeizure,
             .handleFalseAlarm,
             .stopFromIphone,
             .stopReceivedFromWatch,
             .stopFromRemoteStreaming,
             .criticalError,
             .lastBPM,
             .termination,
             .streamingUnderstandAlert,
             .activePatientChanged,
             .cantFireNotification,
             .HealthAuthorizationError,
             .watchNotReachable,
             .noStreamingData,
             .sessionBoot:
            return SoundOptions.shared.notificationSound
        }
    }
}

// MARK: making Events Codable
extension Events {
    private enum CodingKeys: String, CodingKey {
        case alarm, manualAlarm, warning, noData, lastBPM, lowBatteryWatch,
             lowBatteryIphone, unclassifiedEvent, handleSeizure, handleFalseAlarm,
             stopReceivedFromWatch, stopFromIphone, stopFromRemoteChild, criticalError,
             sessionBoot, medicationAlert, medicationSnooze, termination, testSound,
             streamingUnderstandAlert, activePatientChanged, cantFireNotification, healthAuthError, watchNotReachable
    }

    private enum MetaDataKeys: String, CodingKey { case metaData }
    private enum BpmKeys: String, CodingKey { case bpm, metaData}
    private enum HandleFalseAlarmKeys: String, CodingKey { case firingBpm, notes}
    private enum CriticalerrorKeys: String, CodingKey { case errorMessage }
    private enum TestSoundKeys: String, CodingKey { case critical, delay }
    private enum CantFireNotificationKeys: String, CodingKey { case errorMessage}
    private enum HealthAuthErrorKeys: String, CodingKey { case errorMessage }

    // swiftlint: disable cyclomatic_complexity
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .lowBatteryWatch(metaData):
            var lowBatteryContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .lowBatteryWatch)
            try lowBatteryContainer.encode(metaData, forKey: .metaData)
        case let .lastBPM(bpm, metaData):
            var lastBPMContainer = container.nestedContainer(keyedBy: BpmKeys.self, forKey: .lastBPM)
            try lastBPMContainer.encode(bpm, forKey: .bpm)
            try lastBPMContainer.encode(metaData, forKey: .metaData)
        case .handleFalseAlarm(let firingBPM, let notes):
            var handleFalseAlarmContainer = container.nestedContainer(keyedBy: HandleFalseAlarmKeys.self, forKey: .handleFalseAlarm)
            try handleFalseAlarmContainer.encode(firingBPM, forKey: .firingBpm)
            try handleFalseAlarmContainer.encode(notes, forKey: .notes)
        case .termination:
            try container.encode(true, forKey: .termination)
        case .watchNotReachable:
            try container.encode(true, forKey: .watchNotReachable)
        case .noLocalData(let metaData), .noStreamingData(let metaData):
            var noDataContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .noData)
            try noDataContainer.encode(metaData, forKey: .metaData)
        case .manualAlarm(let metaData):
            var manualAlarmContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .manualAlarm)
            try manualAlarmContainer.encode(metaData, forKey: .metaData)
        case .streamingUnderstandAlert:
            try container.encode(true, forKey: .streamingUnderstandAlert)
        case .medicationSnooze:
            try container.encode(true, forKey: .medicationSnooze)
        case .cantFireNotification(errorMessage: let errorMessage):
            var nestedContainer = container.nestedContainer(keyedBy: CantFireNotificationKeys.self, forKey: .cantFireNotification)
            try nestedContainer.encode(errorMessage, forKey: .errorMessage)
        case .medicationAlert:
            try container.encode(true, forKey: .medicationAlert)
        case .alarm(let metaData):
            var nestedContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .alarm)
            try nestedContainer.encode(metaData, forKey: .metaData)
        case .warning(metaData: let metaData):
            var nestedContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .warning)
            try nestedContainer.encode(metaData, forKey: .metaData)
        case .lowBatteryIphone(metaData: let metaData):
            var nestedContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .lowBatteryIphone)
            try nestedContainer.encode(metaData, forKey: .metaData)
        case .unclassifiedEvent(metaData: let metaData):
            var nestedContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .unclassifiedEvent)
            try nestedContainer.encode(metaData, forKey: .metaData)
        case .handleSeizure(metaData: let metaData):
            var nestedContainer = container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .handleSeizure)
            try nestedContainer.encode(metaData, forKey: .metaData)
        case .stopReceivedFromWatch:
            try container.encode(true, forKey: .stopReceivedFromWatch)
        case .stopFromIphone:
            try container.encode(true, forKey: .stopFromIphone)
        case .stopFromRemoteStreaming:
            try container.encode(true, forKey: .stopFromRemoteChild)
        case .criticalError(errorMessage: let errorMessage):
            var nestedContainer = container.nestedContainer(keyedBy: CriticalerrorKeys.self, forKey: .criticalError)
            try nestedContainer.encode(errorMessage, forKey: .errorMessage)
        case .HealthAuthorizationError(errorMessage: let errorMessage):
            var nestedContainer = container.nestedContainer(keyedBy: HealthAuthErrorKeys.self, forKey: .healthAuthError)
            try nestedContainer.encode(errorMessage, forKey: .errorMessage)
        case .testSound(critical: let critical, delay: let delay):
            var nestedContainer = container.nestedContainer(keyedBy: TestSoundKeys.self, forKey: .testSound)
            try nestedContainer.encode(critical, forKey: .critical)
            try nestedContainer.encode(delay, forKey: .delay)
        case .sessionBoot:
            try container.encode(true, forKey: .sessionBoot)
        case .activePatientChanged:
            try container.encode(true, forKey: .activePatientChanged)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let alarmContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .alarm),
           let metaData = try? alarmContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .alarm(metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .manualAlarm),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .manualAlarm(metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .handleSeizure),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .handleSeizure(metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: BpmKeys.self, forKey: .lastBPM),
           let bpm = try? nestedContainer.decode(Int.self, forKey: .bpm),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .lastBPM(bpm, metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .lowBatteryIphone),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .lowBatteryIphone(metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .lowBatteryWatch),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .lowBatteryWatch(metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: CantFireNotificationKeys.self, forKey: .cantFireNotification),
           let errorMessage = try? nestedContainer.decode(String.self, forKey: .errorMessage) {
            self = .cantFireNotification(errorMessage: errorMessage)
            return
        }

        if container.contains(.stopReceivedFromWatch) {
            self = .stopReceivedFromWatch
            return
        }
        if container.contains(.stopFromIphone) {
            self = .stopFromIphone
            return
        }
        if container.contains(.stopFromRemoteChild) {
            self = .stopFromRemoteStreaming
            return
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CriticalerrorKeys.self, forKey: .criticalError),
           let errorMessage = try? nestedContainer.decode(String.self, forKey: .errorMessage) {
            self = .criticalError(errorMessage: errorMessage)
            return
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: HealthAuthErrorKeys.self, forKey: .healthAuthError),
           let errorMessage = try? nestedContainer.decode(String.self, forKey: .errorMessage) {
            self = .HealthAuthorizationError(errorMessage: errorMessage)
            return
        }
        
        if container.contains(.sessionBoot) {
            self = .sessionBoot
            return
        }
        
        if container.contains(.medicationAlert) {
            self = .medicationAlert
            return
        }
        
        if container.contains(.medicationSnooze) {
            self = .medicationSnooze
            return
        }
        
        if container.contains(.streamingUnderstandAlert) {
            self = .streamingUnderstandAlert
            return
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: HandleFalseAlarmKeys.self, forKey: .handleFalseAlarm),
           let firingBpm = try? nestedContainer.decode(Int.self, forKey: .firingBpm),
           let notes = try? nestedContainer.decode(String.self, forKey: .notes) {
            self = .handleFalseAlarm(firingBPM: firingBpm, notes: notes)
            return
        }
        if container.contains(.termination) {
            self = .termination
            return
        }
        if container.contains(.watchNotReachable) {
            self = .watchNotReachable
            return
        }
        if container.contains(.activePatientChanged) {
            self = .activePatientChanged
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .noData),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .noLocalData(metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .warning),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .warning(metaData: metaData)
            return
        }
        if let nestedContainer = try? container.nestedContainer(keyedBy: MetaDataKeys.self, forKey: .unclassifiedEvent),
           let metaData = try? nestedContainer.decode(EventMetaData.self, forKey: .metaData) {
            self = .unclassifiedEvent(metaData: metaData)
            return
        }

        if let nestedContainer = try? container.nestedContainer(keyedBy: TestSoundKeys.self, forKey: .testSound),
           let critical = try? nestedContainer.decode(Bool.self, forKey: .critical),
           let delay = try? nestedContainer.decode(TimeInterval.self, forKey: .delay) {
            self = .testSound(critical: critical, delay: delay)
            return
        }
        mainDebugger.append("Unable to decode Event", .error, sourceModule: "Events - init from decoder")
        throw NSError(domain: "Events codable", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Unable to decode Event"])
    }

    public var jsonString: String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error)
            return nil
        }
    }
    
    public static func loadFromJson(jsonString: String) -> Events? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(Events.self, from: data)
    }
}
// swiftlint: enable cyclomatic_complexity

// MARK: EVENTMETADATA Struct
public struct EventMetaData: Codable {
    public var name: String
    public var valueString: String?
    public var valueInt: Int?
    public var valueTimeInterval: TimeInterval?
    
    public init(name: String, valueInt: Int) {
        self.name = name
        self.valueInt = valueInt
    }
    
    public init(name: String, valueString: String) {
        self.name = name
        self.valueString = valueString
    }
    
    public init(name: String, valueTimeInterval: TimeInterval) {
        self.name = name
        self.valueTimeInterval = valueTimeInterval
    }
    
    public var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error)
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> EventMetaData? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(EventMetaData.self, from: data)
    }
    
    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        // Inserisci sempre `name` perché è obbligatorio
        dictionary["name"] = name
        
        // Aggiungi gli altri campi solo se hanno un valore non-nil
        if let valueString = valueString {
            dictionary["valueString"] = valueString
        }
        
        if let valueInt = valueInt {
            dictionary["valueInt"] = valueInt
        }
        
        if let valueTimeInterval = valueTimeInterval {
            dictionary["valueTimeInterval"] = valueTimeInterval
        }
        
        return dictionary
    }

}

extension Events {
    public static var testEvents: [Events] = [
        .alarm(metaData: .init(name: "ALARM", valueInt: 150)),
        .noLocalData(metaData: .init(name: "NODATA", valueInt: 45)),
        .warning(metaData: .init(name: "WARNING", valueString: "TEST")),
        .lastBPM(134, metaData: .init(name: "LASTBPM", valueTimeInterval: 45)),
        .stopFromIphone,
        .stopReceivedFromWatch,
        .termination,
        .medicationAlert,
        .medicationSnooze,
        .streamingUnderstandAlert,
        .activePatientChanged,
        .manualAlarm(metaData: .init(name: "MANUALALARM", valueInt: 45)),
        .lowBatteryWatch(metaData: .init(name: "LOWBATTERYWATCH", valueInt: 5)),
        .lowBatteryIphone(metaData: .init(name: "LOWBATTERYIPHONE", valueInt: 6)),
        .unclassifiedEvent(metaData: .init(name: "UNCLASSIFIED", valueString: "BOH")),
        .handleFalseAlarm(firingBPM: 680, notes: "note false alarm"),
        .handleSeizure(metaData: .init(name: "HANDLESEIZURES", valueInt: 67)),
        .criticalError(errorMessage: "TestError"),
        .testSound(critical: true, delay: 56),
        .sessionBoot
    ]
    
    public static func == (lhs: Events, rhs: Events) -> Bool {
        lhs.description == rhs.description
    }
}
