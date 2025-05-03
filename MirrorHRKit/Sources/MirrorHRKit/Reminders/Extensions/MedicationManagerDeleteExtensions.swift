//
//  MedicationManagerDeleteExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UserNotifications
import SharedPkg

extension MedicationManager {
    public func deleteRecurrenceAt(_ recurrence: Recurrence, _ reminderTime: String) {
        let matchingReminders = filterRemindersBy(recurrence)
            .filter { reminder in
                guard let reminderTrigger = reminder.trigger as? UNCalendarNotificationTrigger else {
                    return false
                }
                let reminderComponents = reminderTrigger.dateComponents
                let curtesyDate = calendar.date(from: reminderComponents)
                return curtesyDate?.returnHHmm() == reminderTime ? true : false
            }
        matchingReminders.forEach { reminder in
            notificationManager.removePendingRequestWithIdentifier(reminder.identifier) { _ in
                Task {
                    await self.fetch()
                }
            }
        }
    }
    
    public func deleteNotificationRequest(_ notificationRequest: UNNotificationRequest) {
        notificationManager.removePendingRequestWithIdentifier(notificationRequest.identifier) { _ in
            Task {
                await self.fetch()
            }
        }
    }

    public func deleteAll() {
        cancelPendingMedicationReminders(completion: { _ in
            Task {
                await self.fetch()
            }
            mainDebugger.append("Deleted medication reminders", .event)
        })
    }
}
