//
//  MeasurementsUnit.swift
//  
//
//  Created by Roberto D’Angelo on 30/12/21.
//

import Foundation

public enum MeasurementsUnit: String, Codable, CaseIterable {
    case metric
    case imperialUS
    
    var description: String {
        switch self {
        case .imperialUS: return "Imperial"
        case .metric: return "Metric"
        }
    }
    
    var weightUnit: String {
        switch self {
        case .metric: return "kg"
        case .imperialUS: return "lb"
        }
    }
    
    func convertWeight(value: Double, from: MeasurementsUnit, to: MeasurementsUnit) -> Double {
        let kg2poundsMultiplier: Double = 2.2046
        guard value != 0 else {
            return 0
        }
        
        if from == .metric && to == .imperialUS {
            return value * kg2poundsMultiplier
        }
        if from == .imperialUS && to == .metric {
            return value / kg2poundsMultiplier
        }
        return value
    }
}
