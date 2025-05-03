//
//  StatsExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 19/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg

// MARK: SymptomsManager stast extensions

extension SymptomsManager {
    
    private func filterSymptoms(for symptom: String? = nil) -> [Date] {
        return filteredSymptoms
            .filter { symptomData in
                if let symptom = symptom {
                    return symptomData.symptom == symptom
                }
                return true
            }
            .compactMap { $0.startDate }
    }

    private func generateLast12MonthsStats(from aggregatedData: [String: Int]) -> [ChartSupportStruct] {
        let past12Months = (-11 ... 0).compactMap { Calendar.current.date(byAdding: .month, value: $0, to: Date()) }
        return past12Months.map { month in
            let monthName = Calendar.current.shortMonthSymbols[Calendar.current.component(.month, from: month) - 1]
            let year = Calendar.current.component(.year, from: month)
            let monthYearKey = "\(monthName) \(year)"
            
            return ChartSupportStruct(dictionary: Dictionary4Charts(key: monthName, value: aggregatedData[monthYearKey] ?? 0), statsType: .last12months, foreignIndex: Calendar.current.component(.month, from: month))
        }
    }

    private func aggregateDatesByMonth(dates: [Date]) -> [String: Int] {
        var aggregatedData: [String: Int] = [:]
        
        for date in dates {
            let month = Calendar.current.component(.month, from: date)
            let year = Calendar.current.component(.year, from: date)
            let monthName = Calendar.current.shortMonthSymbols[month - 1] // Use shortMonthSymbols
            let monthYearKey = "\(monthName) \(year)"
            aggregatedData[monthYearKey, default: 0] += 1
        }
        
        return aggregatedData
    }


    private func getFilteredSymptomDates(for symptom: String?) -> [Date] {
        return filterSymptoms(for: symptom)
    }

    func returnStatsByLast12Month(for symptom: String? = nil) -> [ChartSupportStruct] {
        // Step 1: Filter the symptom dates
        let symptomsDates = getFilteredSymptomDates(for: symptom)

        // Step 2: Aggregate by month
        let aggregatedData = aggregateDatesByMonth(dates: symptomsDates)

        // Step 3: Generate stats for the last 12 months
        let stats = generateLast12MonthsStats(from: aggregatedData)

        return stats
    }

    
    func returnLast4WeeksStatsByWeek(for symptom: String? = nil) -> [ChartSupportStruct] {
        let symptomsDates = filterSymptoms(for: symptom)
        var aggregatedData: [String: Int] = [:]
        let maxWeeks = 4
        
        for date in symptomsDates {
            let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
            let year = Calendar.current.component(.year, from: date)
            let weekKey = "\(year)-Week \(weekOfYear)"
            aggregatedData[weekKey, default: 0] += 1
        }
        
        let results = (0..<maxWeeks).map { weekOffset in
            let date = Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
            let year = Calendar.current.component(.year, from: date)
            let weekKey = "\(year)-Week \(weekOfYear)"
            
            return ChartSupportStruct(dictionary: Dictionary4Charts(key: weekKey, value: aggregatedData[weekKey] ?? 0), statsType: .last4weeks, foreignIndex: weekOffset)
        }
        
        return Array(results.reversed())
    }



    func returnStatsByWeekDay(for symptom: String? = nil) -> [ChartSupportStruct] {
        let symptomsDates = filterSymptoms(for: symptom)
        var aggregatedData: [String: Int] = [:]
        
        for date in symptomsDates {
            let weekday = Calendar.current.component(.weekday, from: date)
            let weekdayName = Calendar.current.shortWeekdaySymbols[weekday - 1]
            aggregatedData[weekdayName, default: 0] += 1
        }
        
        return Calendar.current.shortWeekdaySymbols.enumerated().map { index, weekdayName in
            return ChartSupportStruct(dictionary: Dictionary4Charts(key: weekdayName, value: aggregatedData[weekdayName] ?? 0), statsType: .byWeekDay, foreignIndex: index)
        }
    }
}

