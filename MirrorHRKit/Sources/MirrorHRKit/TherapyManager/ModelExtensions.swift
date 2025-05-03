//
//  ModelExtensions.swift
//
//
//  Created by Roberto D’Angelo on 30/04/22.
//

import Foundation
import CoreData
import SharedPkg

extension Therapy {
    var validityDateInterval: String {
        guard let startDate = startDate, let endDate = endDate else {
            return ""
        }
        return "\(startDate.toDayMonthYear()) " + " -> " + "\(endDate.toDayMonthYear())"
    }
    
    var cocktailList: [Cocktail] {
        guard let list = cocktails as? Set<Cocktail> else {
            return []
        }
        return list.map { cocktail in
            cocktail
        }.sorted { lhs, rhs in
            guard let lhsReminder = lhs.reminder, let rhsReminder = rhs.reminder else {
                return false
            }
            return lhsReminder < rhsReminder
        }
    }
    
    var drugsList: [Drug] {
        var drugs: [Drug] = []
        for cocktail in cocktailList {
            drugs.append(contentsOf: cocktail.drugsList)
        }
        return drugs.unique()
    }
    
    var reminderList: [Date]? {
        return cocktailList.map { cocktail in
            guard let reminder = cocktail.reminder else {
                return Date(timeIntervalSince1970: 0)
            }
            return reminder
        }.unique() 
    }
}

extension Cocktail {
    var dosesList: [Dose] {
        guard let list = doses as? Set<Dose> else {
            return []
        }
        return list.map { dose in
            dose
        }.sorted {lhs, rhs in
            guard let lhsDrug = lhs.drug, let lhsDrugName = lhsDrug.name, let rhsDrug = rhs.drug, let rhsDrugName = rhsDrug.name else {
                return false
            }
            return lhsDrugName < rhsDrugName
        }
    }
    
    var drugsList: [Drug] {
        var drugs: [Drug] = []
        _ = dosesList.map { dose in
            if let drug = dose.drug {
                drugs.append(drug)
            }
        }
        return drugs.unique()
    }
}
