//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 05/12/21.
//

import Foundation
import UserNotifications
import SharedPkg

extension NotificationManager {
    func scheduleNewNoLocalDataNotification() {
        removePendingNoDataCheckNotifications()
        if KISSFlowManager.shared.currentStage != .stopped {
            let maxInterval = Double(KeyFlowThresholds.shared.maxIntervalWithoutData)
            let when = UNTimeIntervalNotificationTrigger(timeInterval: maxInterval, repeats: true)
            let metaData: EventMetaData = .init(name: "NODATAFOR", valueInt: Int(round(maxInterval)))
            NotificationManager.shared.fireRecurringNotificationCheck(.noLocalData(metaData: metaData), when)
            let securityWhen = UNTimeIntervalNotificationTrigger(timeInterval: maxInterval*2, repeats: true)
            NotificationManager.shared.fireRecurringNotificationCheck(.noLocalData(metaData: metaData), securityWhen)
        }
    }
    
    func removePendingNoDataCheckNotifications() {
        let noDataEvent = Events.noLocalData(metaData: .init(name: "NODATAFOR", valueInt: 0))

        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [noDataEvent.description]
        )
        
        notificationCenter.getPendingNotificationRequests { notificationRequests in
            var identifiers: [String] = []
            for notification: UNNotificationRequest in notificationRequests {
                let isNoData: Bool = notification.identifier.contains(noDataEventStringV2) || notification.identifier.contains("No Data") || notification.identifier.contains("noDataEventStringV2") ||
                notification.identifier.contains("NoDataEventString") ||
                notification.identifier.contains("noDataEventString") ||
                notification.identifier.contains("NoDataEventStringV2".local()) ||
                notification.identifier.contains("noDataEventString".local())
                if isNoData {
                    identifiers.append(notification.identifier)
                }
            }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}
