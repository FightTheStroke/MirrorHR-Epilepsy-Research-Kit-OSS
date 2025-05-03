//
//  QuickLogs.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 18/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg

enum StatsType {
    case last4weeks
    case last12months
    case byWeekDay
    case byMonth
    case byYear
}

struct Dictionary4Charts: Equatable, Hashable {
    var key: String
    var value: Int
}

struct ChartSupportStruct: Equatable, Hashable {
    var dictionary: Dictionary4Charts
    var statsType: StatsType
    var foreignIndex: Int?
}
