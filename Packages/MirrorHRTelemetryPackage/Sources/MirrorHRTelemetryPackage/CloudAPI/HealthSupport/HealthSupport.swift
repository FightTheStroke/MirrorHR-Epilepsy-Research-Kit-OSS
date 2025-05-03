//
//  HealthSupport.swift
//  
//
//  Created by Roberto D’Angelo on 09/08/22.
//

import Foundation
import HealthKit

internal enum HealthAuthorizationStatus {
    case success
    case quantityTypeUnavailable
    case healthDataUnavailable
    case dataTypeNotAvailable
    case error(error: Error?)
}

internal protocol HealthAuthorizationProtocol: AnyObject {
    var authorized: Bool { get }

    func requestAuthorizationToReadHeartRateData(completion: @escaping (_ status: HealthAuthorizationStatus) -> Void)
}

internal final class HealthAuthorizationManager: HealthAuthorizationProtocol {
    typealias Status = HealthAuthorizationStatus
    public private(set) var authorized: Bool = false
    private let healthStore = HKHealthStore()

    public init() {}
    
    public func requestAuthorizationToReadHeartRateData(completion: @escaping (_ status: HealthAuthorizationStatus) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() == true else {
            completion(.healthDataUnavailable)
            return
        }

        // MARK: important: categoried and data we leverage
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(.dataTypeNotAvailable)
            return
        }

        // MARK: this is important, it's the list of types we handle

        let healthKitTypesToWrite: Set<HKSampleType> = [heartRate]

        let healthKitTypesToRead: Set<HKObjectType> = [heartRate]

        // 4. Request Authorization

        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { success, error in
            if error != nil {
                self.authorized = false
                dispatchTelemetryEvent(event: .mirrorHRError(sourceModule: "CloudAPI internal HealthAuthorizationManager", error: "Error: \(error?.localizedDescription ?? "unknown")"))
                completion(.error(error: error))
            } else {
                self.authorized = success
                completion(.success)
            }
        }
    }
}
