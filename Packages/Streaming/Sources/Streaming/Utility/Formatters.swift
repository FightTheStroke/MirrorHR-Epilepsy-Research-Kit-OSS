//
//  Formatters.swift
//
//
//  Created by Roberto D’Angelo on 12/08/22.
//

import Foundation

internal extension NumberFormatter {
  static var currency: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    return numberFormatter
  }()
}

internal extension DateFormatter {
  static var dueDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()

  static var timestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()
}

internal extension Date {
    static let dayMonthYear = "dd-MM-yyyy"
    static let preciseTime = "HH:mm:ss.SSS"
    static let dateFormatter = DateFormatter()
    static let stdDateFormat = "dd-MM-yyyy HH:mm:ss"
    
    func toDayMonthYear() -> String {
        Date.dateFormatter.dateFormat = Date.dayMonthYear
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
