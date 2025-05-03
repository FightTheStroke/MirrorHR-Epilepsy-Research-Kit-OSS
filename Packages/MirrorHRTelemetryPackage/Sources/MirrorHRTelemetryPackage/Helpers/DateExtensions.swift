//
//  DateExtensions.swift
//  
//
//  Created by Roberto D’Angelo on 09/08/22.
//

import Foundation

internal extension Date {
    static let dayMonthYear = "dd-MM-yyyy"
    static let preciseTime = "HH:mm:ss.SSS"
    static let stdTime = "HH:mm:ss"
    static let dateFormatter = DateFormatter()
    static let stdDateFormat = "dd-MM-yyyy HH:mm:ss"
    
    func toDayMonthYear() -> String {
        Date.dateFormatter.dateFormat = Date.dayMonthYear
        return Date.dateFormatter.string(from: self)
    }
    
    func toStdTime() -> String {
        Date.dateFormatter.dateFormat = Date.stdTime
        return Date.dateFormatter.string(from: self)
    }
    
    func toPreciseTime() -> String {
        Date.dateFormatter.dateFormat = Date.preciseTime
        return Date.dateFormatter.string(from: self)
    }
    
    func daysAgo(number: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: -number, to: self)!
    }
    
    func toStdString() -> String {
        Date.dateFormatter.dateFormat = Date.stdDateFormat
        return Date.dateFormatter.string(from: self)
    }
}

extension Date {
    static var timeStampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func universalTimeStamp() -> String {
        let currentLocale = Locale.current
        let dateFormatter = Date.timeStampFormatter
        dateFormatter.locale = currentLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Specify the input date format

        let gregorianCalendar = Calendar(identifier: .gregorian)
        let components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

        if let gregorianDate = gregorianCalendar.date(from: components) {
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss" // Specify the desired output date format
            return dateFormatter.string(from: gregorianDate)
        } else {
            return toStdString() // If the conversion fails, return nil
        }
    }
}
