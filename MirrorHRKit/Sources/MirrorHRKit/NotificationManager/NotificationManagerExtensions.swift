//
//  NotificationManagerExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import UserNotifications
import SharedPkg

extension NotificationManager {
    // core private functions
    func fireNotification(_ request: UNNotificationRequest) {
        syncQueue.sync {
            notificationCenter.add(request) { error in
                guard error == nil else {
                    mainDebugger.append("notification error: \(error.debugDescription)", .error, sourceModule: "fireNotification")
                    dispatchMainEvent(.criticalError(errorMessage: error.debugDescription), "NotificationManager")
                    return
                }
            }
        }
    }

    func notificationContent(from event: Events) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = event.description
        content.title = "MirrorHR " + event.notificationTitle
        content.interruptionLevel = .critical
        content.sound = UNNotificationSound.criticalSoundNamed(
            UNNotificationSoundName(rawValue: event.notificationSound),
            withAudioVolume: Float(SoundOptions.shared.alarmSoundVolume)
        )
        content.threadIdentifier = event.description
        content.body = event.notificationBody
        return content
    }


    public func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handleMirrorHRNotifications(notification: notification)
        let userInfo = notification.request.content.userInfo
        
        // Check for the 'content-available' key to identify silent notifications
        if let aps = userInfo["aps"] as? [String: AnyObject], let contentAvailable = aps["content-available"] as? Int, contentAvailable == 1 {
            // Handle silent notification specifics here if needed
            // Complete with no presentation options for truly silent update
            completionHandler([])
        } else {
            // For regular notifications, customize based on your app needs
            completionHandler([.banner, .badge, .sound])
        }
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleMirrorHRNotifications(response: response)
        observers.forEach { observer in
            observer.userNotificationCenter?(center, didReceive: response, withCompletionHandler: {})
        }
        completionHandler()
    }

    func fireCalendarNotificationRequest(_ event: Events, _ when: UNCalendarNotificationTrigger) {
        let identifierSuffix = extractSuffix(from: when) ?? UUID().uuidString
        let request = UNNotificationRequest(
            identifier: event.description.appending(identifierSuffix).appending(UUID().uuidString),
            content: notificationContent(from: event),
            trigger: when
        )
        fireNotification(request)
    }
    
    func fireRecurringNotificationCheck(_ event: Events, _ when: UNTimeIntervalNotificationTrigger) {
        let identifierSuffix = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: event.description.appending(identifierSuffix),
            content: notificationContent(from: event),
            trigger: when
        )
        fireNotification(request)
    }

    private func extractSuffix(from trigger: UNCalendarNotificationTrigger) -> String? {
        guard
            let notificationHour = trigger.dateComponents.hour,
            let notificationMinute = trigger.dateComponents.minute
        else {
            return nil
        }

        return "-" + "\(notificationHour):\(notificationMinute)" + "-"
    }
}
