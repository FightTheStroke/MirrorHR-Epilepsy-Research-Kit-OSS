//
//  DateCountersExtension.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 19/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import RoberdanToolBox
import SwiftUI
import SharedPkg

extension SymptomsManager {
    func seizuresCount() -> Int {
        return seizuresOnlyData.count
    }
    
    func oldestSymptomDate() -> Date {
        return symptomsData.last?.startDate ?? Date()
    }
    
    func alarmsInDateRange(lowerDate: Date, upperDate: Date) -> [SymptomsData] {
        let alarmsOnlySymptomsArray: [HandledSymptomsEvents] = [.highBPM, .lowBPM, .seizure]
        return symptomsData
            .filter { sympt in
                guard let symptom = sympt.symptom else {
                    return false
                }
                return alarmsOnlySymptomsArray.contains(HandledSymptomsEvents(rawValue: symptom) ?? .none)
            }
            .filter({ sympt in
                guard let startDate = sympt.startDate, let endDate = sympt.endDate else {
                    return false
                }
                return startDate >= lowerDate && endDate <= upperDate
            })
    }
    
    func seizuresCountInDateRange(lowerDate: Date, upperDate: Date) -> Int {
        let cnt = symptomsData
            .filter { sympt in
                seizuresLogOnlySymptomsArray.contains(HandledSymptomsEvents(rawValue: sympt.symptom!) ?? .none)
            }
            .filter({ sympt in
                guard let startDate = sympt.startDate else {
                    return false
                }
                return startDate >= lowerDate && startDate <= upperDate
            })
            .count
        return cnt
    }
    
    func seizuresInDateRange(lowerDate: Date, upperDate: Date) -> [SymptomsData] {
        return symptomsData
            .filter { sympt in
                seizuresLogOnlySymptomsArray.contains(HandledSymptomsEvents(rawValue: sympt.symptom!) ?? .none)
            }
            .filter({ sympt in
                guard let startDate = sympt.startDate else {
                    return false
                }
                return startDate >= lowerDate && startDate <= upperDate
            })
    }
    
    func falseAlarmsInDataRange(lowerDate: Date, upperDate: Date) -> [SymptomsData] {
        let falseAlarmsOnlySymptomsArray: [HandledSymptomsEvents] = [.highBPM, .lowBPM]
        return symptomsData
            .filter { sympt in
                falseAlarmsOnlySymptomsArray.contains(HandledSymptomsEvents(rawValue: sympt.symptom!) ?? .none)
            }
            .filter({ sympt in
                guard let startDate = sympt.startDate else {
                    return false
                }
                return startDate >= lowerDate && startDate <= upperDate
            })
    }
    
    var symptomLogsByDateCmptSeizuresForCharts: [DateComponents] {
        filteredSymptoms
            .map { symptom -> DateComponents in
                Calendar.current.dateComponents([.day, .weekday, .year, .month], from: symptom.startDate ?? noStartDate)
            }
    }
    
    func sinceLastSeizureString(split: Bool = false) -> (complete: String, sinceLastSeizure: String, lastDateOnly: String) {
        
        // 1. Extract the last event date
        guard let lastEvent = getLastSeizureDate() else {
            return (congratsNoSeizureMsg, congratsNoSeizureMsg, congratsNoSeizureMsg)
        }

        // 2. Calculate the time difference between now and the last event
        let sinceLast = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: lastEvent, to: Date())

        guard let days = sinceLast.day, let hours = sinceLast.hour, let minutes = sinceLast.minute else {
            fatalError("Unexpected nil values when extracting date components.")
        }

        // 3. Build the string representations
        let completeString = "\(days)\(dayIndicatorString) \(hours)\(hoursIndicatorString) \(minutes)\(minutesIndicatorString) \(sinceLastEventString) \(lastEvent.timelineDateHeader())".capitalizingFirstLetter()
        let sinceLastSeizureString = "\("SinceLastSeizureString".local().capitalizingFirstLetter()) \(lastEvent.toHomeString())"
        let lastDateOnlyString = "\(days)\(dayIndicatorString) \(hours)\(hoursIndicatorString) \(minutes)\(minutesIndicatorString)"

        return (completeString, sinceLastSeizureString, lastDateOnlyString)
    }

    private func getLastSeizureDate() -> Date? {
        return seizuresOnlyData.first?.endDate
    }
    
    func sinceLastEvent() -> String {
        if let lastEvent = filteredSymptoms
                .first?.endDate {
            let sinceLast = Calendar.current.dateComponents(
                [.day, .hour, .minute, .second],
                from: lastEvent,
                to: Date()
            )
            return ("\(sinceLast.day!)\(dayIndicatorString) \(sinceLast.hour!)\(hoursIndicatorString) \(sinceLast.minute!)\(minutesIndicatorString) \(sinceLastEventString) \(lastEvent.timelineDateHeader())")
        } else {
            return emptySinceLastEventString
        }
    }
    
    func distanceBetweenLastAndPreviousEvent() -> String {
        if filteredSymptoms.count > 1 {
            let last2Events = filteredSymptoms.prefix(2) // only last 2 seizures array
            guard let lastEventDate = last2Events.first?.endDate,
                  let previousLast = last2Events.last?.endDate else {
                return ""
            }
            
            let sinceLast = Calendar.current.dateComponents(
                [.day, .hour, .minute, .second],
                from: previousLast,
                to: lastEventDate
            )
            
            return (intervalBetweenLast2Seizures + ": \(sinceLast.day!)\(dayIndicatorString) \(sinceLast.hour!)\(hoursIndicatorString) \(sinceLast.minute!)\(minutesIndicatorString)")
            
        } else {
            return ""
        }
    }
    
    func distanceBetweenLastAndPreviousSeizure() -> String {
        if seizuresCount() > 1 {
            let seizuresDataOnly: [SymptomsData] = symptomsData.filter { sympt in
                sympt.symptom == HandledSymptomsEvents.seizure.rawValue
            }
            
            let last2Seizures = seizuresDataOnly.prefix(2) // only last 2 seizures array
            guard let lastSeizureDate = last2Seizures.first?.endDate,
                  let previousLast = last2Seizures.last?.endDate else {
                return ""
            }
            
            let sinceLast = Calendar.current.dateComponents(
                [.day, .hour, .minute, .second],
                from: previousLast,
                to: lastSeizureDate
            )
            
            return (intervalBetweenLast2Seizures + ": \(sinceLast.day!)\(dayIndicatorString) \(sinceLast.hour!)\(hoursIndicatorString) \(sinceLast.minute!)\(minutesIndicatorString) (\(previousLast.toShort()))")
        } else {
            return ""
        }
    }
}
