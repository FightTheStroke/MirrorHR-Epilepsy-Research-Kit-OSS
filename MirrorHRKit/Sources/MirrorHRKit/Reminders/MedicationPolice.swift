//
//  MedicationPolice.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 22/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import UserNotifications
import SharedPkg

public extension MedicationManager {
    func checkForMedicationForgotten() {
        notificationCenter.getPendingNotificationRequests { notifications in
            self.checkForMedicationForgotten(notifications: notifications)
        }
    }

    private func checkForMedicationForgotten(notifications: [UNNotificationRequest]) {
        let now = Date()
        let todayDateComponents = now.components([.weekday, .hour, .minute, .second])
        let todaysNotificationsTimes = notifications.compactMap {
            $0.getHourMinuteFor(weekday: todayDateComponents.weekday)
        }

        todaysNotificationsTimes.forEach { time in
            guard let notificationDate = extractNotificationDate(for: todayDateComponents, now: now, time: time) else {
                return
            }
            if thirtyMinHasPassed(between: notificationDate, and: now) {
                trackMedicationForgottenIfNeeded(from: notificationDate)
            }
        }
    }

    private func extractNotificationDate(
        for todayDateComponents: DateComponents,
        now: Date,
        time: (hour: Int, minute: Int)
    ) -> Date? {
        guard
            let todayHour = todayDateComponents.hour,
            let todayMinute = todayDateComponents.minute,
            let todaySecond = todayDateComponents.second
        else {
            // can't compute today's timing
            return nil
        }

        return computeNotificationTime(
            now: now,
            nowComponents: Time(hour: todayHour.double, minute: todayMinute.double, second: todaySecond.double),
            notificationComponents: (hour: time.hour.double, minute: time.minute.double)
        )
    }

    private func thirtyMinHasPassed(
        between notificationDate: Date,
        and now: Date
    ) -> Bool {
        notificationDate.distance(to: now) > 30 * 60
    }

    private struct Time {
        let hour: Double
        let minute: Double
        let second: Double
    }

    private func computeNotificationTime(
        now: Date,
        nowComponents: Time,
        notificationComponents: (hour: Double, minute: Double)
    ) -> Date {
        let oneMinute = 60.0 // sec
        let oneHour = 60.0 * oneMinute

        return now.addingTimeInterval(-nowComponents.hour * oneHour) // reset hour to 0
            .addingTimeInterval(-nowComponents.minute * oneMinute) // reset minutes to 0
            .addingTimeInterval(-nowComponents.second) // reset the seconds to 0
            .addingTimeInterval(notificationComponents.hour * oneHour) // move the hours to the notification hour
            .addingTimeInterval(notificationComponents.minute * oneMinute) // move the minutes to the notification hour
    }

    private func trackMedicationForgottenIfNeeded(from notificationDate: Date) {
        // check whether there have been a medication taken in that time interval
        // otherwise track a medication missed.
        let missedMedication = notificationDate.advanced(by: 30 * 60)
        let medicationHasBeenTaken = SymptomsManager.shared.medicationTakenExists(
            between: notificationDate,
            endDate: missedMedication
        )
        // Let's consider missedMedication +- 30 sec to account for date errors
        let medicationNotTakenAlreadyLogged = SymptomsManager.shared.medicationForgottenExists(
            between: missedMedication.addingTimeInterval(-30),
            endDate: missedMedication.addingTimeInterval(30)
        )
        if !medicationHasBeenTaken.exist, !medicationNotTakenAlreadyLogged {
            DispatchQueue.global().async {
                SymptomLog(.medicationForgotten, startDate: missedMedication, endDate: missedMedication).append { _ in
                    mainDebugger.append("medication forgotten thx to missed notification", .event)
                }
            }
        }
    }
}

// MARK: - Helper Extension

extension Date {
    func components(_ calendarComponents: Set<Calendar.Component>) -> DateComponents {
        Calendar.autoupdatingCurrent.dateComponents(calendarComponents, from: self)
    }
}

extension UNNotificationRequest {
    var calendarTrigger: UNCalendarNotificationTrigger? {
        trigger as? UNCalendarNotificationTrigger
    }

    var weekday: Int? {
        calendarTrigger?.dateComponents.weekday
    }

    var hour: Int? {
        calendarTrigger?.dateComponents.hour
    }

    var minute: Int? {
        calendarTrigger?.dateComponents.minute
    }

    func getHourMinuteFor(weekday: Int?) -> (hour: Int, minute: Int)? {
        guard
            let wd = weekday, // altrimenti se sia weekday sia self.weekday sono `nil` il check successivo é true
            self.weekday == wd,
            let hour = hour,
            let minute = minute
        else {
            return nil
        }
        return (hour: hour, minute: minute)
    }
}

extension Int {
    var double: Double {
        Double(self)
    }
}

extension MedicationManager {
    enum MedicationStatus {
        case taken, missed, partial, overdose, loading
    }
    
    func medicationStatusForCurrentWeek() async -> [MedicationStatus?] {
        var statusArray: [MedicationStatus?] = Array(repeating: .loading, count: 7)
        let symptomsManager: SymptomsManager = .shared
        let calendar = Calendar.current
        let today = Date()
        let firstDayOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        let reminders = await self.remindersForCurrentWeek()
        
        
        for index in 0..<7 {
            let dayBeingProcessed = calendar.date(byAdding: .day, value: index, to: firstDayOfCurrentWeek)!
            
            // If the day hasn't occurred yet this week, set status to none and skip further processing
            if dayBeingProcessed > today {
                statusArray[index] = .none
                continue
            }
            
            let weekdayIndex = calendar.component(.weekday, from: dayBeingProcessed)
            let expectedReminders = reminders[weekdayIndex] ?? 0
            
            let currentComponents = calendar.dateComponents([.year, .weekOfYear], from: today)
            let thisWeekSymptoms = symptomsManager.symptomsData.filter {
                guard let endDate = $0.endDate else { return false }
                let symptomComponents = calendar.dateComponents([.year, .weekOfYear], from: endDate)
                return symptomComponents.year == currentComponents.year && symptomComponents.weekOfYear == currentComponents.weekOfYear
            }
            
            let thisDaySymptoms = thisWeekSymptoms.filter {
                $0.endDate?.weekDayInt() == weekdayIndex
            }
            
            let medicationsTakenCount = thisDaySymptoms.filter {
                $0.symptom == HandledSymptomsEvents.medicationTaken.rawValue
            }.count
            
            let medicationsForgottenCount = thisDaySymptoms.filter {
                $0.symptom == HandledSymptomsEvents.medicationForgotten.rawValue
            }.count
            
            if medicationsTakenCount > expectedReminders {
                statusArray[index] = .overdose
            } else if expectedReminders == medicationsTakenCount {
                statusArray[index] = .taken
            } else if expectedReminders == medicationsForgottenCount {
                statusArray[index] = .missed
            } else if medicationsTakenCount > 0 {
                statusArray[index] = .partial
            } else {
                statusArray[index] = .none
            }
        }
        return statusArray
    }
}

extension MedicationManager {
    
    // This function returns a dictionary with keys as days of the week (indices) and values as the count of reminders for each day.
    func remindersForCurrentWeek() async -> [Int: Int] {
        await fetch()  // Ensure fetch completes first.
        
        var remindersCount: [Int: Int] = [:]
        
        // Initialize with zeros
        for i in 1...7 {  // 1 (Sunday) to 7 (Saturday)
            remindersCount[i] = 0
        }
        
        // Iterate over each medication reminder.
        for request in medicationAsyncReminders {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let weekday = trigger.dateComponents.weekday {
                remindersCount[weekday]! += 1
            }
        }
        return remindersCount
    }
}
