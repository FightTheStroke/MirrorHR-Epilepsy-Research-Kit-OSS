//
//  MedicationManagerEnums.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg

public extension MedicationManager {
    enum Recurrence: CaseIterable {
        case weekDays
        case weekEnds
        case wholeWeek

        static var oldReminderPicker: [Recurrence] {
            return [.weekDays, .weekEnds]
        }
        
        var title: String {
            switch self {
            case .weekDays:
                return weekdaysString
            case .weekEnds:
                return weekendString
            case .wholeWeek:
                return weekdaysString
            }
        }

        var days: [Int] {
            switch self {
            case .weekDays:
                return [2, 3, 4, 5, 6]
            case .weekEnds:
                return [1, 7]
            case .wholeWeek:
                return [1, 2, 3, 4, 5, 6, 7]
            }
        }
    }
}
