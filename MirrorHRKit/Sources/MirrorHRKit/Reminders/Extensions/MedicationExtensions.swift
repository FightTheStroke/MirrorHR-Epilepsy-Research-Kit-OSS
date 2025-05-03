//
//  MedicationExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import UserNotifications
import SharedPkg

/// Thread-safe extensions for MedicationManager
internal extension MedicationManager {
    /// Retrieves scheduled medication reminders
    /// - Returns: Array of notification requests
    /// - Note: Uses continuation for proper async handling
    func getScheduledMedicationReminders() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            notificationCenter.getPendingNotificationRequests { notificationRequests in
                let reminders = notificationRequests.filter { notification in
                    notification.identifier.contains(Events.medicationAlert.description)
                }
                mainDebugger.append("Get scheduled medication reminders: \(reminders.count)", .event)
                continuation.resume(returning: reminders)
            }
        }
    }


    func getPendingNotifications(completion: @escaping (_ requests: [UNNotificationRequest]) -> Void) {
        var pendingNotificationsReqs: [UNNotificationRequest] = []
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            pendingNotificationsReqs = requests
        })
        mainDebugger.append("GetPendingNotifications: \(pendingNotificationsReqs.count)", .justALog)
        completion(pendingNotificationsReqs)
    }

    func cancelPendingMedicationReminders(completion: @escaping (_ done: Bool) -> Void) {
        notificationCenter.getPendingNotificationRequests { notificationRequests in
            var identifiers: [String] = []
            for notification: UNNotificationRequest in notificationRequests {
                let isMedicationReminder: Bool = notification.identifier.contains(Events.medicationAlert.description)
                let isMedicationSnooze: Bool = notification.identifier.contains(Events.medicationSnooze.description)
                if isMedicationReminder || isMedicationSnooze {
                    identifiers.append(notification.identifier)
                }
            }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
            mainDebugger.append("candelPendingMedicationsReminder", .event)
            completion(true)
        }
    }

    func filterRemindersBy(_ recurrence: Recurrence) -> [UNNotificationRequest] {
        medicationReminders
            .filter { reminder in
                guard let weekDay = returnReminderWeekDay(reminder) else {
                    return false
                }
                if recurrence.days.contains(weekDay) {
                    return true
                } else {
                    return false
                }
            }
    }

    func delete(_ reminder: UNNotificationRequest) {
        notificationManager.removePendingRequestWithIdentifier(reminder.identifier) { _ in
            Task {
                await self.fetch()
            }
        }
    }

    func getNextTriggerDateFor(_ reminder: UNNotificationRequest) -> Date? {
        if let calendarNotificationTrigger = reminder.trigger as? UNCalendarNotificationTrigger,
           let nextTriggerDate = calendarNotificationTrigger.nextTriggerDate() {
            return (nextTriggerDate)
        }
        return nil
    }

    func returnReminderWeekDay(_ reminder: UNNotificationRequest) -> Int? {
        if let calendarNotificationTrigger = reminder.trigger as? UNCalendarNotificationTrigger,
           let nextTriggerDate = calendarNotificationTrigger.nextTriggerDate() {
            let weekDay = nextTriggerDate.weekDayInt()
            return weekDay
        }
        return nil
    }

    // Create Date from picker selected value.
    func createDate(weekday: Int, hour: Int, minute: Int, year: Int = Date().year) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.weekday = weekday // sunday = 1 ... saturday = 7
        components.year = year
        components.weekdayOrdinal = 10
        components.timeZone = .current
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components) ?? Date()
    }

    func showReminderSummary(_ reminder: UNNotificationRequest) -> String {
        if let calendarNotificationTrigger = reminder.trigger as? UNCalendarNotificationTrigger,
           let nextTriggerDate = calendarNotificationTrigger.nextTriggerDate() {
            let weekDay = nextTriggerDate.weekDaySymbol()
            let timing = nextTriggerDate.returnHHmm()
            return weekDay + " " + timing
        }
        return "Reminder error"
    }
}
