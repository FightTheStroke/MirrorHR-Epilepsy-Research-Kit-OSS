//
//  NotificationManagerFiringExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import MirrorHRTelemetryPackage
import RoberdanToolBox
import SharedPkg
import SwiftUI
import UserNotifications

extension NotificationManager {
    public func handleEvents(event: Events) {
        syncQueue.sync {
            fireNotification(
                event: event, overrideLastFiredDelay: false,
                triggerInterval: 0.1)
        }
    }

    // swiftlint:disable all
    // MARK: here is where all the notification firing happen
    public func fireNotification(
        event: Events,
        overrideLastFiredDelay: Bool = true,
        triggerInterval: TimeInterval? = nil,
        category: UNNotificationCategory? = nil,
        customMetaData: EventMetaData? = nil
    ) {
        // if I can notify then I fire it
        if authorizationStatus != .authorized {
            askPermissions()
        }

        let currentTime = Date()
        let intervalBetweenAlarmNotificationInSecs =
            overrideLastFiredDelay
            ? 0 : defaultIntervalBetweenAlarmsAndNotifications

        let identifier = event.description.appending(UUID().uuidString)
        if triggerInterval != nil {
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: triggerInterval ?? 0.1, repeats: false)
        }
        let content = notificationContent(from: event)
        content.userInfo = customMetaData?.toDictionary() ?? [:]
        var notification: UNNotificationRequest?

        switch event {
        case .alarm:
            let difference =
                currentTime.timeIntervalSince1970 - lastAlarmNotificationFired
            if difference >= intervalBetweenAlarmNotificationInSecs,
                !realTimeEventsManager.alarmIsSilent
            {
                notification = UNNotificationRequest(
                    identifier: identifier, content: content, trigger: trigger)
                SymptomsManager.shared.fireTelemetryControlSymptoms(
                    SymptomLog(.alarmFired, notes: content.body))
                lastAlarmNotificationFired = currentTime.timeIntervalSince1970
            }

        case .lastBPM:
            break
        case let .noLocalData(metaData):
            let noDataFor =
                metaData.valueTimeInterval
                ?? Double(KeyFlowThresholds.shared.maxIntervalWithoutData + 1)
            if noDataFor
                > Double(KeyFlowThresholds.shared.maxIntervalWithoutData)
            {
                notification = UNNotificationRequest(
                    identifier: identifier, content: content, trigger: trigger)
            }

        case .noStreamingData:
            break

        case .stopReceivedFromWatch, .stopFromIphone, .stopFromRemoteStreaming,
            .unclassifiedEvent(metaData: _):
            if settings.notifyWhenRealtimeMonitorEnds {
                notification = UNNotificationRequest(
                    identifier: identifier, content: content, trigger: trigger)
            }

        case .criticalError(let errorMessage):
            let difference =
                currentTime.timeIntervalSince1970
                - lastCriticalErrorNotificationFired
            if difference >= intervalBetweenAlarmNotificationInSecs,
                !realTimeEventsManager.criticalErrorNotificationsAreSilent
            {
                content.userInfo = ["Error": errorMessage]
                notification = UNNotificationRequest(
                    identifier: identifier, content: content, trigger: trigger)
                lastCriticalErrorNotificationFired =
                    currentTime.timeIntervalSince1970
            }

        case .testSound(critical: _, let delay):
            let delayTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: delay, repeats: false)
            notification = UNNotificationRequest(
                identifier: identifier, content: content, trigger: delayTrigger)

        case .medicationSnooze:
            if let category = category {
                notificationCenter.setNotificationCategories([category])
            }
            notification = UNNotificationRequest(
                identifier: identifier, content: content, trigger: trigger)
            mainDebugger.append(
                "snoozing medication reminder", .event,
                sourceModule: "NotificationManager fire notification")

        case let .lowBatteryWatch(metaData):
            let difference =
                currentTime.timeIntervalSince1970 - lastBatteryNotificationFired
            if difference >= intervalBetweenAlarmNotificationInSecs,
                !realTimeEventsManager.batteryIsSilent
            {
                content.userInfo = metaData.toDictionary()
                notification = UNNotificationRequest(
                    identifier: identifier, content: content, trigger: trigger)
                lastBatteryNotificationFired = currentTime.timeIntervalSince1970
            }

        case let .lowBatteryIphone(metaData: metaData):
            content.userInfo = metaData.toDictionary()
            notification = UNNotificationRequest(
                identifier: identifier, content: content, trigger: trigger)

        case .termination:
            // it only fires the notification. If you try to add any other action it does not fire anymore the notification :(
            notification = UNNotificationRequest(
                identifier: identifier, content: content, trigger: trigger)
            removePendingNoDataCheckNotifications()
        //            MirrorHRMainClass.shared.sendStopFromIphoneToWatch()
        case .medicationAlert,
            .warning,
            .handleSeizure,
            .handleFalseAlarm,
            .manualAlarm,
            .activePatientChanged,
            .streamingUnderstandAlert,
            .cantFireNotification,
            .HealthAuthorizationError,
            .sessionBoot:
            break
        case .watchNotReachable:
            if case .running = MirrorHRMainClass.shared.status {
                let difference =
                    currentTime.timeIntervalSince1970
                    - lastCriticalErrorNotificationFired
                if difference >= intervalBetweenAlarmNotificationInSecs,
                    !realTimeEventsManager.criticalErrorNotificationsAreSilent
                {
                    notification = UNNotificationRequest(
                        identifier: identifier, content: content,
                        trigger: trigger)
                    lastCriticalErrorNotificationFired =
                        currentTime.timeIntervalSince1970
                }
            }
        }

        guard let notification = notification else {
            return
        }

        fireNotification(notification)
    }
    // swiftlint:enable all

    public func handleMirrorHRNotifications(
        notification: UNNotification? = nil,
        response: UNNotificationResponse? = nil
    ) {
        if let notification = notification {
            let content = notification.request.content
            if content.categoryIdentifier.contains(noDataEventStringV2)
                && settings.appleWatchEnabled
            {
                DispatchQueue.main.async {
                    KISSFlowManager.shared.currentStage = .noLocalData
                    TabViewController.shared.tabView =
                        Tab.realtimeMonitor.rawValue
                }
            }
        }

        if let response = response {
            let content = response.notification.request.content
            let userInfo = content.userInfo
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier,
                UNNotificationDismissActionIdentifier:
                if content.categoryIdentifier.contains(
                    Events.medicationAlert.description)
                    || content.categoryIdentifier.contains(
                        Events.medicationSnooze.description)
                {
                    mainDebugger.append(
                        "Medication Manager Notification Metadata: \(userInfo)",
                        .event)
                    MedicationManager.shared.handleMedicationViaAlert()
                }

            default:
                break
            }
        }
    }

    public func testAlarmNotifications(critical: Bool) {
        if critical {
            dispatchMainEvent(
                .alarm(metaData: .init(name: "BPM", valueInt: 136)),
                "test alarm notification")
        } else {
            dispatchMainEvent(
                .noLocalData(
                    metaData: .init(
                        name: "NODATAFOR", valueTimeInterval: round(5.3))),
                "test alarm notification")
        }
    }
}
