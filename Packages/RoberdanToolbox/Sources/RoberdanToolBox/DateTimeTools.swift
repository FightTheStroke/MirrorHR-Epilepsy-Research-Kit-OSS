//  DateTimeTools.swift
//
//  Created by Roberto D’Angelo on 21/04/2020.
//  Copyright © 2020 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

let dateFormatter = DateFormatter()

// extension for easily handle timeinterval outcomes in string and different formats
@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
public class MainTimer: ObservableObject {
    public static let shared = MainTimer()
    
    @Published public var now: TimeInterval = Date().timeIntervalSince1970
    @Published public var sinceStartingTime: TimeInterval = 0
    
    private var startingTime: TimeInterval?
    
    private init() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.now = Date().timeIntervalSince1970
                guard let startingTime = self.startingTime else {
                    return
                }
                self.sinceStartingTime = self.now - startingTime
            }
        }
    }
    
    public func startTimer() {
        sinceStartingTime = 0
        startingTime = Date().timeIntervalSince1970
    }
    
    public func stopTimer() {
        startingTime = nil
    }
}

extension TimeInterval {
    internal static let timeStampFormatterHHmmss: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    public func timeClockFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date(timeIntervalSince1970: self))
    }
    
    public func timeClockFullFormatter() -> String {
        Self.timeStampFormatterHHmmss.string(
            from: Date(timeIntervalSince1970: self))
    }
    
    public func secsOnly() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter.string(from: Date(timeIntervalSince1970: self))
    }
    
    public func toTimeStampFormatter() -> String {
        Self.timeStampFormatterHHmmss.string(
            from: Date(timeIntervalSince1970: self))
    }
    
    public func timeStampHHmmFormatter() -> String {
        Self.timeStampFormatterHHmmss.string(
            from: Date(timeIntervalSince1970: self))
    }
    
    public func toHHmmssString() -> String {
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        let returnedHs =
        (hours == 0 ? "00:" : (hours < 10 ? "0\(hours):" : "\(hours):"))
        let returnedStringMin =
        (minutes == 0
         ? "00:" : (minutes < 10 ? "0\(minutes):" : "\(minutes):"))
        let returnedSeconds =
        (seconds == 0
         ? "00" : (seconds < 10 ? "0\(seconds)" : "\(seconds)"))
        return (returnedHs + returnedStringMin + returnedSeconds)
    }
    
    public func toSmartHHMMssString() -> String {
        var returnedStringMin: String
        var returnedStringHH: String
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        if hours > 0 {
            returnedStringHH = ((hours < 10) ? "0\(hours):" : "\(hours):")
        } else {
            returnedStringHH = ""
        }
        if minutes > 0 {
            returnedStringMin = (minutes < 10 ? "0\(minutes):" : "\(minutes):")
        } else {
            returnedStringMin = ""
        }
        
        let returnedSeconds =
        ((seconds < 10 && minutes > 0) ? "0\(seconds)" : "\(seconds)")
        return (returnedStringHH + returnedStringMin + returnedSeconds)
    }
    
    public func toFullHHMMssString() -> String {
        var returnedStringMin: String
        var returnedStringHH: String
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        if minutes > 0 {
            returnedStringMin = (minutes < 10 ? "0\(minutes):" : "\(minutes):")
        } else {
            returnedStringMin = "00:"
        }
        
        if hours > 0 {
            returnedStringHH = ((hours < 10) ? "0\(hours):" : "\(hours):")
        } else {
            returnedStringHH = "00:"
        }
        let returnedSeconds = ((seconds < 10) ? "0\(seconds)" : "\(seconds)")
        return (returnedStringHH + returnedStringMin + returnedSeconds)
    }
    
    public func toMMssStringWatch() -> String {
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let returnedStringMin = (minutes < 10 ? "0\(minutes):" : "\(minutes):")
        let returnedSeconds = (seconds < 10 ? "0\(seconds)" : "\(seconds)")
        return ((minutes > 0 ? returnedStringMin : "") + returnedSeconds)
    }
    
    public func toFullText() -> String {
        let time = Int(self)
        let milliSeconds = String(
            Int(truncatingRemainder(dividingBy: 1) * 1000))
        let seconds = String(time % 60)
        let minutes = String((time / 60) % 60)
        let hours = String(time / 3600)
        return (hours + ":" + minutes + ":" + seconds + ":" + milliSeconds)
    }
    
    public func toHHmmss() -> String {
        let time = Int(self)
        let seconds = String(time % 60)
        let minutes = String((time / 60) % 60)
        let hours = String(time / 3600)
        return (hours + ":" + minutes + ":" + seconds)
    }
    
    public func toHHmm() -> String {
        let time = Int(self)
        let minutes = String((time / 60) % 60)
        let hours = String(time / 3600)
        return (hours + " hs : " + minutes + " min")
    }
    
    public func toHistoryViewFormat() -> String {
        let dateTmp = Date(timeIntervalSince1970: self)
        return dateTmp.returnDDmmYY()
    }
}

// it enables to easily have date in string formats
@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
extension Date {
    //    Date.yesterday    // "Oct 28, 2018 at 12:00 PM"
    //    Date()            // "Oct 29, 2018 at 11:01 AM"
    //    Date.tomorrow     // "Oct 30, 2018 at 12:00 PM"
    //
    //    Date.tomorrow.month   // 10
    //    Date().isLastDayOfMonth  // false
    
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
    
    public func weekDaySymbol() -> String {
        let components = Calendar.current.dateComponents([.weekday], from: self)
        return Calendar.current.weekdaySymbols[components.weekday! - 1]
    }
    
    public func weekDayInt() -> Int? {
        let components = Calendar.current.dateComponents([.weekday], from: self)
        return components.weekday
    }
    
    public static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate
        - rhs.timeIntervalSinceReferenceDate
    }
    
    public static var yesterday: Date { Date().dayBefore }
    public static var tomorrow: Date { Date().dayAfter }
    public static var todayDiary: Date { Date().today }
    public static let stdDateFormat = "dd-MM-yyyy HH:mm:ss"
    public static let preciseDateFormat = "dd-MM-yy HH:mm:ss.SSS"
    public static let dayMonthYear = "dd-MM-yyyy"
    public static let preciseTime = "HH:mm:ss.SSS"
    public static let stdTime = "HH:mm:ss"
    public static let nightInterval = [21, 8]
    
    public var startOfDay: Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
    }
    
    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
    
    public var dayBefore: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    public var dayAfter: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    public var noon: Date {
        Calendar.current.date(
            bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    public var today: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    public var midnight: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    public func toStdString() -> String {
        dateFormatter.dateFormat = Date.stdDateFormat
        return dateFormatter.string(from: self)
    }
    
    public func toDayMonthYear() -> String {
        dateFormatter.dateFormat = Date.dayMonthYear
        return dateFormatter.string(from: self)
    }
    
    public func toPreciseTime() -> String {
        dateFormatter.dateFormat = Date.preciseTime
        return dateFormatter.string(from: self)
    }
    
    public func toStdTime() -> String {
        dateFormatter.dateFormat = Date.stdTime
        return dateFormatter.string(from: self)
    }
    
    public func toPreciseString() -> String {
        dateFormatter.dateFormat = Date.preciseDateFormat
        return dateFormatter.string(from: self)
    }
    
    public var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    public var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    public var isLastDayOfMonth: Bool {
        dayAfter.month != month
    }
    
    public func returnHHmm() -> String {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    public static func fromStdDateString(_ dateString: String) -> Date? {
        dateFormatter.dateFormat = Date.stdDateFormat
        return dateFormatter.date(from: dateString)
    }
    
    public func returnDDmmYY() -> String {
        let components = Calendar.current.dateComponents(
            [.day, .month, .year], from: self)
        let day = components.day!
        let month = components.month!
        let year = components.year!
        let monthName = DateFormatter().monthSymbols[month - 1]
        return "\(day), \(monthName) \(year)"
    }
    
    public func returnCloudPathForML() -> String {
        dateFormatter.dateFormat = "/yyyy/MM/dd/"
        return dateFormatter.string(from: self)
    }
    
    public func addMonth(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: number, to: self)!
    }
    
    public func addDay(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: number, to: self)!
    }
    
    public func addSec(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: number, to: self)!
    }
    
    public func monthsAgo(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: -number, to: self)!
    }
    
    public func daysAgo(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: -number, to: self)!
    }
    
    public func hoursAgo(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .hour, value: -number, to: self)!
    }
    
    public func addHour(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .hour, value: number, to: self)!
    }
    
    public func minsAgo(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .minute, value: -number, to: self)!
    }
    
    public func addMins(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .minute, value: number, to: self)!
    }
    
    public func secsAgo(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: -number, to: self)!
    }
    
    public func lastDays(_ number: Int) -> Date {
        let delta = TimeInterval(number * 24 * 60 * 60)
        let newTime = timeIntervalSince1970 - delta
        return Date(timeIntervalSince1970: newTime)
    }
    
    public func deltaHours(_ number: Int) -> Date {
        let delta = TimeInterval(number * 60 * 60)
        let newTime = timeIntervalSince1970 + delta
        return Date(timeIntervalSince1970: newTime)
    }
    
    public func hours2Int() -> Int {
        dateFormatter.dateFormat = "HH"
        return Int(dateFormatter.string(from: self)) ?? 0
    }
    
    public func minutes() -> String {
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: self)
    }
    
    public func seconds() -> String {
        dateFormatter.dateFormat = "ss"
        return dateFormatter.string(from: self)
    }
    
#if os(iOS)
    func isNight() -> Bool {
        var isNight = false
        if hours2Int() < Date.nightInterval[1]
            || hours2Int() > Date.nightInterval[0]
        {
            isNight = true
        }
        return isNight
    }
    
    func isDay() -> Bool {
        var isDay = false
        if hours2Int() >= Date.nightInterval[1]
            || hours2Int() <= Date.nightInterval[0]
        {
            isDay = true
        }
        return isDay
    }
#endif
}

extension Date {
    //    static let stdDateFormat = "dd-MM-yyyy HH:mm:ss"
    
    public func returnFileName() -> String {
        dateFormatter.dateFormat = "dd-MM-yyyy-HH-mm-ss"
        return dateFormatter.string(from: self)
    }
    
    public func toShort() -> String {
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
    
    public func toHomeString() -> String {
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: self)
    }
    
    public func day() -> String {
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
}

extension Date {
    public func compareVideoLogDates() -> String {
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: self)
    }
    
    public func get(
        _ components: Calendar.Component...,
        calendar: Calendar = Calendar.current
    ) -> DateComponents {
        calendar.dateComponents(Set(components), from: self)
    }
    
    public func get(
        _ component: Calendar.Component, calendar: Calendar = Calendar.current
    ) -> Int {
        calendar.component(component, from: self)
    }
    
    public func timelineDateHeader() -> String {
        let components = get(.day, .month, .year, .weekday)
        
        let weekday = components.weekday ?? 1
        let weekDay = Calendar.current.shortWeekdaySymbols[weekday - 1]
        let month = components.month ?? 1
        let monthSymbol = Calendar.current.shortMonthSymbols[month - 1]
        let weekdayString = "\(weekDay)".capitalizingFirstLetter()
        let monthString = "\(monthSymbol)".capitalizingFirstLetter()
        return weekdayString + " \(components.day ?? 0) " + monthString
        + " \(components.year ?? 1970)"
    }
    
    public static func fromTimeLineDateHeader2Date(dateHeader: String) -> Date {
        dateFormatter.dateFormat = "E dd MMMM yyyy"
        return dateFormatter.date(from: dateHeader)
        ?? Date(timeIntervalSince1970: 0)
    }
    
    public func dateHeader() -> String {
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
    
    public func sinceTodayString() -> String {
        let today = Date()
        let calendar = Calendar.current
        
        // Calcola il numero di giorni tra la data e oggi
        let sinceToday = calendar.dateComponents([.day], from: self, to: today)
        
        if let days = sinceToday.day, days > 0 {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full  // Puoi scegliere tra .full, .short, .abbreviated
            let dayString = formatter.localizedString(from: .init(day: -days))
            return "\(self.dateHeader().capitalizingFirstLetter())\n(\(dayString))"
        } else {
            return self.dateHeader().capitalizingFirstLetter()
        }
        
    }
    
    public func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2)...max(date1, date2)).contains(self)
    }
}
