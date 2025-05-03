//
//  HealthQuantitiesEnum.swift
//  
//
//  Created by Roberto D’Angelo on 27/12/21.
//

import Foundation
import HealthKit

enum HealthQuantity: String, CaseIterable {
    case hrv = "HRVString"
    case oxygen = "OxygenSaturationString"
    case respiratoryRate = "RespiratoryRateString"
    
    var hKtype: HKQuantityType? {
        switch self {
        case .hrv:
            return HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .oxygen:
            return HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)
        case .respiratoryRate:
            return HKQuantityType.quantityType(forIdentifier: .respiratoryRate)
        }
    }
    
    var label: String {
        return self.rawValue.local()
    }
    
    var unit: String {
        switch self {
        case .hrv:
            return "ms"
        case .oxygen:
            return "%"
        case .respiratoryRate:
            return "cpm"
        }
    }
    
    var image: String {
        switch self {
        case .hrv: return "waveform.path.ecg"
        case .oxygen: return "drop"
        case.respiratoryRate: return "sun.min"
        }
    }
    
    var stringFormat: String {
        switch self {
        case .hrv:
            return "%.2f"
        case .oxygen:
            return "%.0f"
        case .respiratoryRate:
            return "%.1f"
        }
    }
    
    func calculateValue (value: Double) -> Double {
        switch self {
        case .hrv, .respiratoryRate:
            return value
        case .oxygen:
            return value * 100
        }
    }
    
    var hKUnit: HKUnit {
        switch self {
        case .hrv:
            return HKUnit(from: "ms")
        case .oxygen:
            return HKUnit(from: "%")
        case .respiratoryRate:
            return HKUnit(from: "count/min")
        }
    }
}
