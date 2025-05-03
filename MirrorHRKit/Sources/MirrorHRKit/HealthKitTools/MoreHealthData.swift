//
//  MoreHealthData.swift
//  
//
//  Created by Roberto D'Angelo on 25/12/21.
//

import Foundation
import SwiftUI
import HealthKit
import SharedPkg
import RoberdanToolBox

class ReadHealthData: ObservableObject, Identifiable {
    @Published var minValue: Double?
    @Published var maxValue: Double?
    @Published var minMaxReadyString: String?
    
    internal static let healthAuthorizationManager: HealthAuthorizationProtocol = HealthAuthorizationManager()
    internal static let healthStore = HKHealthStore()
    var healthQuantity: HealthQuantity
    var id: UUID
    
    init(_ healthQuantity: HealthQuantity) {
        self.healthQuantity = healthQuantity
        id = UUID()
        guard let healthQuantityType = healthQuantity.hKtype else {
            mainDebugger.append("Data type for \(healthQuantity.rawValue) NOT available", .error, sourceModule: "ReadHealthData init")
            return
        }
        
        ReadHealthData.healthStore.requestAuthorization(toShare: nil, read: [healthQuantityType]) { success, error in
            guard error == nil, success == true else {
                mainDebugger.append("Can't have authorization to read \(healthQuantity.rawValue)", .error, sourceModule: "ReadHealthData request authorization")
                return
            }
        }
    }
    
    func readMinMax(for date: Date) {
        readMinMax(startDate: date.startOfDay, endDate: date.endOfDay)
    }
    
    func readMinMax(startDate: Date, endDate: Date, completion: @escaping (_ min: Double?, _ max: Double?, _ error: Error?) -> Void) {
        readAllValues(startDate: startDate, endDate: endDate) { allValues, error in
            guard error == nil else {
                completion(nil, nil, error)
                return
            }
            guard !allValues.isEmpty else {
                completion(nil, nil, nil)
                return
            }
            completion(allValues.min(), allValues.max(), nil)
        }
    }
    
    private func returnMinMaxString() {
        guard let minValue = minValue, let maxValue = maxValue else {
            return
        }
        let minString: String = String(format: healthQuantity.stringFormat, healthQuantity.calculateValue(value: minValue))
        let maxString: String = String(format: healthQuantity.stringFormat, healthQuantity.calculateValue(value: maxValue))
        let unit: String = healthQuantity.unit
        minMaxReadyString = ("\(minString)\(unit) - \(maxString)\(unit)")
    }
    
    private func readMinMax(startDate: Date, endDate: Date) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let queryMinValue = HKStatisticsQuery(quantityType: healthQuantity.hKtype!, quantitySamplePredicate: predicate, options: .discreteMin) { [self] _, minSample, error in
            guard error == nil, let minValue = minSample?.minimumQuantity()?.doubleValue(for: healthQuantity.hKUnit) else {
               // mainDebugger.append("Error reading \(healthQuantity.rawValue) Min Value: \(String(describing: error))", .error)
                return
            }
            DispatchQueue.main.async {
                self.minValue = minValue
                self.returnMinMaxString()
            }
        }
        ReadHealthData.healthStore.execute(queryMinValue)

        let queryMaxValue = HKStatisticsQuery(quantityType: healthQuantity.hKtype!, quantitySamplePredicate: predicate, options: .discreteMax) { [self] _, maxSample, error in
            guard error == nil, let maxValue = maxSample?.maximumQuantity()?.doubleValue(for: healthQuantity.hKUnit) else {
               // mainDebugger.append("Error reading \(healthQuantity.rawValue) Max Value: \(String(describing: error))", .error)
                return
            }
            DispatchQueue.main.async {
                self.maxValue = maxValue
                self.returnMinMaxString()
            }
        }
        ReadHealthData.healthStore.execute(queryMaxValue)
    }
    
    private func readAllValues(startDate: Date, endDate: Date, completion: @escaping (_ allValues: [Double], _ error: Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let hrvQuery = HKSampleQuery(sampleType: healthQuantity.hKtype!,
                                     predicate: predicate,
                                     limit: HKObjectQueryNoLimit,
                                     sortDescriptors: sortDescriptors) { [self] _, samples, error in
            guard error == nil, let finalSamples = samples as? [HKQuantitySample]  else {
                // mainDebugger.append("Error reading \(healthQuantity.rawValue) Values: \(String(describing: error))", .error)
                completion([], error)
                return
            }
            var allValues: [Double] = []
            let hkUnit = healthQuantity.hKUnit
            finalSamples.forEach { sample in
                allValues.append(sample.quantity.doubleValue(for: hkUnit))
            }
            DispatchQueue.main.async {
                completion(allValues, nil)
            }
        }
        ReadHealthData.healthStore.execute(hrvQuery)
    }
    
    static func == (lhs: ReadHealthData, rhs: ReadHealthData) -> Bool {
        lhs.id == rhs.id
    }
}

// TODO: remove this class and refactor only sleep
/// Extended health data management class
/// - Provides additional health metrics beyond basic heart rate
/// - Implements ObservableObject for real-time updates
/// - Handles complex health data queries
/// - Manages health data synchronization
class MoreHealthData: ObservableObject {
    private var startDate: Date = Date().startOfDay
    private var endDate: Date? = Date().endOfDay
    private let healthAuthorizationManager: HealthAuthorizationProtocol = HealthAuthorizationManager()
    private let healthStore = HKHealthStore()
    private let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
    
    func readSleep() {
        let startDate = startDate
        let endDate = startDate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let sleepQuery = HKSampleQuery(sampleType: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
                                       predicate: predicate,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard error == nil, let sleepSamples = samples as? [HKCategorySample]  else {
                mainDebugger.append("Error reading Sleep data: \(String(describing: error))", .error, sourceModule: "readSleep")
                return
            }
            var inBedTotalTime: Double = 0
            sleepSamples.filter { sleepSample in
                sleepSample.value == HKCategoryValueSleepAnalysis.inBed.rawValue
            }.forEach { inBedSample in
                let interval = inBedSample.endDate.timeIntervalSince(inBedSample.startDate)
                inBedTotalTime += interval
            }
            mainDebugger.append("Sleep Total for \(startDate.toStdString()): \(inBedTotalTime.toHHmm())", .justALog, sourceModule: "MoreHealthData")
//            DispatchQueue.main.async {
//                sleepSamples.forEach { sample in
//
//                }
//                printToConsole("=========")
//                printToConsole("Sleep for \("\(startDate.toStdString())")")
//                printToConsole(hRVValues)
//                printToConsole("=========")
//            }
        }
        healthStore.execute(sleepQuery)
    }
}
