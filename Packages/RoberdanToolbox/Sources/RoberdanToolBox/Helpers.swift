//
//  Helpers.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 25/09/2020.
//

import Foundation
@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)

public extension Double {
    func convert(fromRange: (Double, Double), toRange: (Double, Double)) -> Double {
        // Example: if self = 1, fromRange = (0,2), toRange = (10,12) -> solution = 11
        var value = self
        value -= fromRange.0
        value /= Double(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
}
