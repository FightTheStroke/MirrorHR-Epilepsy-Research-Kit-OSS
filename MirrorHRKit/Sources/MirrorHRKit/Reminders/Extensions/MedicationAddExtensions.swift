//
//  MedicationAddExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import UserNotifications
import SharedPkg
import RoberdanToolBox
import MirrorHRTelemetryPackage

extension MedicationManager {
    public func scheduleMedicationReminder() {
        recurrence.days.forEach { day in
            let hour = calendar.component(.hour, from: wakeUp)
            let minute = calendar.component(.minute, from: wakeUp)
            let triggerDate: Date = createDate(weekday: day, hour: hour, minute: minute)
            let trigger = Calendar.current.dateComponents([.weekday, .hour, .minute], from: triggerDate)
            let when = UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
            if reminderDoesNotExist(when: when) {
                notificationManager.fireCalendarNotificationRequest(Events.medicationAlert, when)
                mainDebugger.append("Schedule Medication Reminder\n\(when)", .event)
            } else {
                mainDebugger.append("the proposed reminder already exists for \(when), so it's not created again", .justALog)
            }
        }
        dispatchTelemetryEvent(event: .medicationReminders(recurrence: recurrence.title))
        Task {
            await self.fetch()
        }
    }
    
    public func reminderDoesNotExist(when: UNCalendarNotificationTrigger) -> Bool {
        let check = medicationReminders.filter { notificationRequest in
            notificationRequest.trigger == when
        }
        return check.isEmpty
    }
    
    public struct ReminderStruct: Hashable {
        let id: UUID = UUID()
        var weekDay: String
        var hour: Int
        var minute: Int
        var trigger: UNCalendarNotificationTrigger
        var notificationRequest: UNNotificationRequest
    }

    public func weekDaysReminderList(_ recurrence: Recurrence) -> [ReminderStruct] {
        let notificationRequests = filterRemindersBy(recurrence)
        var returnTuple: [ReminderStruct] = []
        notificationRequests.forEach { notificationRequest in
            guard let trigger = notificationRequest.trigger as? UNCalendarNotificationTrigger,
               let weekDayInt = trigger.dateComponents.weekday,
                  let hour = trigger.dateComponents.hour, let minute = trigger.dateComponents.minute else {
                return
            }
            let weekDay = Calendar.current.weekdaySymbols[weekDayInt - 1].capitalizingFirstLetter()
            returnTuple.append(.init(weekDay: weekDay, hour: hour, minute: minute, trigger: trigger, notificationRequest: notificationRequest))
        }
        return returnTuple
    }
    
    public func scheduleTherapyAssociatedMedicationReminder(recurrence: Recurrence, atTime: Date) {
        recurrence.days.forEach { [self] day in
            let hour = calendar.component(.hour, from: atTime)
            let minute = calendar.component(.minute, from: atTime)
            let triggerDate: Date = createDate(weekday: day, hour: hour, minute: minute)
            let trigger = Calendar.current.dateComponents([.weekday, .hour, .minute], from: triggerDate)
            let when = UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
            if reminderDoesNotExist(when: when) {
                notificationManager.fireCalendarNotificationRequest(Events.medicationAlert, when)
                mainDebugger.append("Schedule Medication Reminder\n\(when)", .event)
            } else {
                mainDebugger.append("the proposed reminder already exists, so it's not created again", .event)
            }
        }
        dispatchTelemetryEvent(event: .medicationReminders(recurrence: recurrence.title))
        Task {
            await self.fetch()
        }
    }
}
