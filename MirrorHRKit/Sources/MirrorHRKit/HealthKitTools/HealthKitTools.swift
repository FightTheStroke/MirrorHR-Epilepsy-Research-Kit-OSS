//
//  HealthKitSupport.swift
//  MirrorHR
//
//  Created by Roberto D'Angelo on 05/10/2020.
//

import Combine
import Foundation
import HealthKit
import SharedPkg
import SciChart
import SwiftUI

/// Core class for HealthKit integration and health data management
/// - Manages HealthKit authorization and permissions
/// - Handles health data reading and writing
/// - Provides health metrics calculations
/// - Implements ObservableObject for SwiftUI integration
class HealthKitTools: ObservableObject {
    static var shared = HealthKitTools(healthAuthorizationManager: HealthAuthorizationManager())
    @Published var queryBPMInProgress: Bool = false
    @Published var querySeizuresInProgress: Bool = false
    @Published var analyzedRecordsForInsights: Int = 0
    @Published var dailyMood: DailyMoods = .neutral {
        didSet {
            let metadata = HealthKitMetadaString(dailyMood: dailyMood)
            saveSymptomsWithSeverityToHealthKStore(symptoms: .generalizedBodyAche,
                                                   severity: dailyMood.severityRange,
                                                   startTime: Date(), endTime: Date(),
                                                   metadata: metadata)
        }
    }

    private let healthAuthorizationManager: HealthAuthorizationProtocol = HealthAuthorizationManager()
    public let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private let heartRateUnit = HKUnit(from: "count/min")
    private var endDate = Date()
    private let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
    
    init(healthAuthorizationManager: HealthAuthorizationManager) {
        askHealthAuthorization(healthAuthorizationManager: healthAuthorizationManager)
    }

    func readhBPMfromHealthKitOnDateAndFillChart(startDateQuery: Date, endDateQuery: Date, destinationDataSeries: SCIXyDataSeries, chartSurface: SCIChartSurface) {
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDateQuery, end: endDateQuery, options: HKQueryOptions.strictStartDate)
        mainDebugger.append("predicate query: \(startDateQuery.toStdString()) - \(endDateQuery.toStdString())")

        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors) { [self] _, results, _ in
            guard let samples = results as? [HKQuantitySample] else {
                mainDebugger.append("Error: no data in healthkit", .error, sourceModule: "readhBPMfromHealthKitOnDateAndFillChart")
                DispatchQueue.main.async {
                    self.queryBPMInProgress = false
                }
                return
            }
            DispatchQueue.main.async {
                destinationDataSeries.clear()
                for sample in samples {
                    destinationDataSeries.append(x: sample.endDate, y: sample.quantity.doubleValue(for: self.heartRateUnit))
                }
                chartSurface.zoomExtents()
                self.analyzedRecordsForInsights = samples.count
                self.queryBPMInProgress = false
            }
        }
        healthStore.execute(heartRateQuery)
        DispatchQueue.main.async {
            self.queryBPMInProgress = true
        }
    }
    // swiftlint:enable all
}

extension HealthKitTools {
    /* only symptoms with severity values: restingHeartRate,fainting, fever,
         vomiting,dizziness,diarrhea,fatigue,nausea, headache, coughing,
         constipation, generalizedBodyAche, shortnessOfBreath, soreThroat,
         drySkin,
     */

    func deleteSample(_ sample: HKCategorySample) {
        healthStore.delete(sample) { success, error in
            if success {
                mainDebugger.append("Sample removed from healthKit")
            } else {
                if error != nil {
                    mainDebugger.append("Error in removing Sample from HealthKit: \(error.debugDescription)", .error, sourceModule: "HealthKitTools deleteSample")
                }
            }
        }
    }

    func saveSymptomsWithSeverityToHealthKStore(symptoms: HKCategoryTypeIdentifier, severity: SeverityRanges, startTime: Date, endTime: Date, metadata: HealthKitMetadaString) {
        if let symptomType = HKObjectType.categoryType(forIdentifier: symptoms) {
            var object: HKCategorySample?
            let updatedMetaData = metadata
            object = HKCategorySample(type: symptomType,
                                      value: severity.hKCategoryValueSeverity.rawValue,
                                      start: startTime, end: endTime,
                                      metadata: updatedMetaData.returnMetadataForHealthKitQuery())
            if object != nil {
                healthStore.save(object!, withCompletion: { success, error -> Void in
                    if error != nil {
                        mainDebugger.append("Error: cant't save symptom \(symptoms.rawValue) to the healthkit", .error, sourceModule: "saveSymptomsWithSeverityToHealthKStore")
                        return
                    }
                    if success {
                        mainDebugger.append("Symptom \(symptoms.rawValue) saved to the healthkit")
                        if symptoms == .fainting {
                            dispatchHealthKitEvents(event: .seizuresQueryNeedToRefresh)
                            mainDebugger.append("dispatching event to refresh seizures query", .event)
                        }
                    } else {
                        mainDebugger.append("Error: cant't save symptom \(symptoms.rawValue) to the healthkit: not getting an error but still not success", .error, sourceModule: "saveSymptomsWithSeverityToHealthKStore")
                    }
                })
            }
        }
    }

    func saveSleepDataToHealthStore(startTime: Date, endTime: Date, type: SleepTypes) {
        //    if let type = HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            var object: HKCategorySample?
            // we create new object we want to push in Health app
            switch type {
            case .inBed:
                object = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: startTime, end: endTime)
            case .aSleep:
                object = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue, start: startTime, end: endTime)
            }
            // we now push the object to HealthStore
            if object != nil {
                healthStore.save(object!, withCompletion: { success, error -> Void in
                    if error != nil {
                        mainDebugger.append("Error: cant't save sleep data", .error, sourceModule: "saveSleepDataToHealthStore")
                        return
                    }
                    if success {
                        // mainDebugger.append("Sleep data saved")
                    } else {
                        mainDebugger.append("Error: cant't save sleep data", .error, sourceModule: "saveSleepDataToHealthStore")
                    }
                })
            }
        }
    }
}
