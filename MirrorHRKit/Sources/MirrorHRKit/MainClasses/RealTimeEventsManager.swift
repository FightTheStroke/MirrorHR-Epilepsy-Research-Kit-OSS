//
//  EventsManager.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 14/11/20.
//

import Combine
import Foundation
import SharedPkg
import SwiftUI
import RoberdanToolBox
import MessageUI

public final class RealTimeEventsManager: ObservableObject, @preconcurrency EventsSubscriber {
    // it handle events when the realtime monitor is running, including seizures, false, notifications etc
    public static let shared = RealTimeEventsManager()

    public var eventSubscriber = AnyCancellable {}
    @Published var alarmIsSilent: Bool = true
    @Published var batteryIsSilent: Bool = false
    @Published var criticalErrorNotificationsAreSilent: Bool = false
    @Published var handleAlarmView: Bool = false
    @Published public var showingAlert = false
    @Published public var alert = Alert(title: Text(unplannedEventMsg))
    @Published var mainMessage: String = ""
    @Published var showLowBatterySymbol: Bool = false
    @Published var isShowingMailView: Bool = false
    public var xlsImportExportFullPath: String = ""
    public var firingBPM: Int = 0
    private let dataSourceManager: DataSourceManager
    private let alarm: Alarm
    private let symptomsManager: SymptomsManager

    let silentBatteryButton = Alert.Button.destructive(Text(stopLowBatteryNotificationsMsg)) {
        mainDebugger.append("silencing battery notifications", .justALog)
        RealTimeEventsManager.shared.batteryIsSilent = true
    }
    
    let silentCriticalErrorButton = Alert.Button.destructive(Text("yes_String".local())) {
        mainDebugger.append("silencing critical error notifications", .justALog)
        RealTimeEventsManager.shared.criticalErrorNotificationsAreSilent = true
    }
    
    lazy var shareDataWithDoc = Alert.Button.default(Text(yesString)) { [self] in
        mainDebugger.append("sharing last seizure data with doctor", .justALog)
        let xlsImportExport: XLSImportExport = XLSImportExport()
        let lastDays: Int = 2
        xlsImportExport.shareXlsDataForLast(days: lastDays) { [self] readyToShare in
            self.xlsImportExportFullPath = xlsImportExport.getFullPath()
            self.isShowingMailView = readyToShare
        }
    }
    
    let doNotShareDataWithDoc = Alert.Button.destructive(Text(noString)) {
        // nothing to do
    }
    
    let continueNotificationsButton = Alert.Button.default(Text(continueMsg)) {
        mainDebugger.append("users wants to continue receiving notifications", .justALog)
    }
    
    private init() {
        alarm = .shared
        dataSourceManager = .shared
        symptomsManager = .shared
        eventSubscriber = mainEventsPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: { [weak self] event in
                DispatchQueue.main.async {
                    self?.handleEvents(event: event)
                }
            })
    }

    // swiftlint:disable cyclomatic_complexity
    @MainActor public func handleEvents(event: Events) {
        // handling events from RealTimeEventsManager
        switch event {
        case let .alarm(metaData: metaData):
            if !alarm.isActive, !alarmIsSilent { // avoid multiple alarms and fire only if firealarm is enabled
                guard let firingBPM = metaData.valueInt else {
                    // Display a UIAlertController telling the user to check for an updated app..
                    return
                }
                self.firingBPM = firingBPM
                
                // handle alarm features
                // automatically fired by the flow manager
                alarm.start = KISSFlowManager.shared.firstAlarmReceivedAt
                alarm.metaData = HealthKitMetadaString(notes: firedByMsg + "\(firingBPM)" + bpmMsg1)
                alarm.isActive = true
                alarm.startTracking()
                handleAlarmView = true
                mainMessage = firedAtMsg + "\(alarm.start.toTimeStampFormatter()) " + byBPMofMsg + " \(firingBPM)"
                mainDebugger.append("start handling alarm", .event)
            }
        case let .manualAlarm(metaData: metaData):
            if !alarm.isActive { // avoid multiple alarms and fire only if firealarm is not already running
                guard let firingBPM = metaData.valueInt else {
                    // Display a UIAlertController telling the user to check for an updated app..
                    return
                }
                self.firingBPM = firingBPM
                // handle alarm features
                // triggered manually by the user
                alarm.start = Date().timeIntervalSince1970
                alarm.metaData = HealthKitMetadaString(notes: manualAlarmTriggeredNotesString + " \(firingBPM) " + bpmMsg1)
                alarm.isActive = true
                alarm.startTracking()

                handleAlarmView = true
                mainMessage = manualAlarmTriggeredMsg + " \(alarm.start.toTimeStampFormatter()) " + byBPMofMsg + " \(firingBPM)"
                mainDebugger.append("start handling manually triggered alarm", .event)
            }
        case let .lowBatteryWatch(metaData: metaData):
            Task { @MainActor in
                showingAlert = true
                showLowBatterySymbol = true
                guard let batteryLevel = metaData.valueInt else {
                    // Display a UIAlertController telling the user to check for an updated app..
                    return
                }
                alert = Alert(title: Text(watchBatteryIsMsg + "\(batteryLevel)%"),
                              message: Text(doYouWantLowBatteryNotificationsMsg),
                              primaryButton: silentBatteryButton, secondaryButton: continueNotificationsButton)
            }
        case let .lowBatteryIphone(metaData: metaData):
            Task { @MainActor in
                showingAlert = true
                showLowBatterySymbol = true
                guard let batteryLevel = metaData.valueInt else {
                    return
                }
                alert = Alert(title: Text(iPhoneBatteryIsMsg + "\(batteryLevel)%"),
                              message: Text(doYouWantLowBatteryNotificationsMsg),
                              primaryButton: silentBatteryButton, secondaryButton: continueNotificationsButton)
            }
        case .handleSeizure:
            alarm.saveSeizure()
            handleAlarmView = false
            if MFMailComposeViewController.canSendMail() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5 * 60) { [self] in // wait 5 minutes before asking to send info to the doctor, to avoid stress in the moment of panic
                    showingAlert = true
                    alert = Alert(title: Text("shareWithDoctorTask".local()),
                                  message: Text("waitExportFileMsg".local()),
                                  primaryButton: doNotShareDataWithDoc,
                                  secondaryButton: shareDataWithDoc)
                }
            }
        case let .handleFalseAlarm(firingBPM: firingBPM, notes: notes):
            alarm.saveFalseAlarm(firingBPM: firingBPM, notes: notes, restartMonitorAutomatically: ProfileGenericSettings.shared.parentalControl)
            handleAlarmView = false
        case .stopReceivedFromWatch, .stopFromIphone, .stopFromRemoteStreaming, .termination:
            alarmIsSilent = true
            if handleAlarmView {
                alarm.saveUnspecifiedAlarm()
                handleAlarmView = false
            }
        case .sessionBoot:
            alarmIsSilent = false
        case .criticalError, .HealthAuthorizationError:
            symptomsManager.fireTelemetryControlSymptoms(SymptomLog(.error, notes: event.description))
        case .streamingUnderstandAlert:
            Task { @MainActor in
                alert = Alert(title: Text(importantMsg), message: Text(streamingSectionAlertMsg))
                showingAlert = true
            }
        case .noLocalData:
            symptomsManager.fireTelemetryControlSymptoms(SymptomLog(.noData, notes: event.description))
        case .noStreamingData: // no need to log no data event when receiving data via streaming
            break
        case .medicationSnooze:
            symptomsManager.fireTelemetryControlSymptoms(SymptomLog(.snoozeReminder, notes: event.description))
        case .warning,
             .lastBPM,
             .unclassifiedEvent,
             .testSound,
             .medicationAlert,
             .activePatientChanged,
             .watchNotReachable,
             .cantFireNotification:
            break
        }
    }
}
// swiftlint:enable cyclomatic_complexity

internal class Alarm: ObservableObject {
    static var shared = Alarm()
    @Published var start: TimeInterval = 0
    @Published var end: TimeInterval = 0
    @Published var Lenght: TimeInterval = 0
    @Published var soFar: TimeInterval = 0
    @Published var isActive: Bool = false

    var severity: SeverityRanges?
    var metaData = HealthKitMetadaString()
    private var timer: Timer?
    private let seizures = SymptomsManager.shared
    private var currentTime = MainTimer.shared
    private let kissFlowManager = KISSFlowManager.shared

    func startTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            Task { @MainActor in
                soFar = currentTime.now - start
            }
        }
    }

    func saveSeizure() {
        stopTracking()
        seizures.saveSeizure(startTime: Date(timeIntervalSince1970: start), endTime: Date(timeIntervalSince1970: end), severity: .severe, metadata: metaData)
        
    }

    func saveFalseAlarm(firingBPM: Int, notes: String, restartMonitorAutomatically: Bool) {
        stopTracking()
        metaData.notes = manualFalseAlarmTriggeredMsg + metaData.notes + notes
        let isLowBPM = firingBPM <= kissFlowManager.keyFlowThresholds.alarmMin
        seizures.appendSymptomLog(.init(
            isLowBPM ? .lowBPM : .highBPM,
            startDate: Date(timeIntervalSince1970: start),
            endDate: Date(timeIntervalSince1970: end),
            severity: .mild,
            jsonMetaData: metaData.jsonString,
            notes: metaData.notes
        ))
        
        if restartMonitorAutomatically {
            _ = Timer.scheduledTimer(withTimeInterval: automaticRestartIntervalAfterFalseAlarm, repeats: false) { restartingTimer in
                DispatchQueue.main.async {
                    // it automatically restart the monitoring after x minutes from a false alarm to avoid that someone forget it
                    if case .running = MirrorHRMainClass.shared.status {
                        RealTimeEventsManager.shared.alarmIsSilent = false
                    } else {
                        restartingTimer.invalidate()
                    }
                }
            }
        }
    }

    func saveUnspecifiedAlarm() {
        stopTracking()
        metaData.notes += unclassifiedAlarmStopMsg
        seizures.saveSeizure(startTime: Date(timeIntervalSince1970: start),
                             endTime: Date(timeIntervalSince1970: end),
                             severity: .notPresent, metadata: metaData)
    }

    private func stopTracking() {
        isActive = false
        end = currentTime.now
        kissFlowManager.resetAlarm()
        Lenght = end - start
        timer?.invalidate()
    }
}
