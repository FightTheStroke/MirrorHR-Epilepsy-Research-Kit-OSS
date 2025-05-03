//
//  AllHealthQuantitiesReader.swift
//  
//
//  Created by Roberto D'Angelo on 27/12/21.
//

import Foundation
import SwiftUI
import HealthKit
import SharedPkg

/// Comprehensive health data reader class
/// - Reads all available health quantities from HealthKit
/// - Provides unified interface for health data access
/// - Implements ObservableObject for reactive updates
/// - Manages health data caching and persistence
class AllHealthQuantitiesReader: ObservableObject {
    var healthQuantities: HealthQuantities = HealthQuantities()
    
    func readAllHealthQuantitiesMinMax(startDate: Date, endDate: Date, completion: @escaping (_ healthQuantities: HealthQuantities) -> Void) {
        let group = DispatchGroup()
        var lock = os_unfair_lock()
        
        HealthQuantity.allCases.forEach {[self] healthQuantity in
            group.enter()
            let quantity = ReadHealthData(healthQuantity)
            quantity.readMinMax(startDate: startDate, endDate: endDate) { min, max, error in
                if error == nil, let minValue = min, let maxValue = max {
                    let minCalculatedValue = healthQuantity.calculateValue(value: minValue)
                    let maxCalculatedValue = healthQuantity.calculateValue(value: maxValue)
                    // Need to lock the access to shared memory
                    os_unfair_lock_lock(&lock)
                    self.healthQuantities.quantityValues.append(.init(label: healthQuantity.label,
                                                                      max: maxCalculatedValue, min: minCalculatedValue,
                                                                      unit: healthQuantity.unit, unitFormat: healthQuantity.stringFormat)
                    )
                    // Release the lock
                    os_unfair_lock_unlock(&lock)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [self] in
            completion(healthQuantities)
        }
    }
    
    struct HealthQuantities: Codable {
        var quantityValues: [HealthValue] = []
        
        public func jsonString() -> String {
            do {
                let jsonData = try JSONEncoder().encode(self)
                return String(data: jsonData, encoding: .utf8)!
            } catch {
                mainDebugger.append("can't encode HealthQuantities", .error, sourceModule: "HealthQuantities jsonString func")
                return ""
            }
        }
        
        public static func loadFromJson(jsonString: String) -> HealthQuantities? {
            let data = Data(jsonString.utf8)
            return try? JSONDecoder().decode(HealthQuantities.self, from: data)
        }
    }
    
    struct HealthValue: Codable {
        var label: String
        var max: Double
        var min: Double
        var unit: String
        var unitFormat: String
        
        func print() -> String {
            let minString: String = String(format: unitFormat, min)
            let maxString: String = String(format: unitFormat, max)
            return ("\(label): \(minString)\(unit) - \(maxString)\(unit)")
        }
    }
}
