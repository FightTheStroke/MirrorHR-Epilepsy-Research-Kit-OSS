//
//  HealthRelated.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 21/10/2020.
//

import Foundation
import HealthKit
import RoberdanToolBox
import SwiftUI
import PermissionsManager

public final class HealthAuthorizationManager: HealthAuthorizationProtocol {
    typealias Status = AuthorizationStatus
    public private(set) var authorized: Bool = false
//    var handledSymptoms: [HKObjectType] = []
    private let healthStore = HKHealthStore()

    public init() {}
    public func requestAuthorizationToReadHeartRateData(completion: @escaping (_ status: AuthorizationStatus) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() == true else {
            completion(.notAvailable)
            return
        }

        // MARK: important: categoried and data we leverage
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
              let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate),
              let sleep = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)
//              let fainting = HKObjectType.categoryType(forIdentifier: .fainting),
//              let fever = HKObjectType.categoryType(forIdentifier: .fever),
//              let nausea = HKObjectType.categoryType(forIdentifier: .nausea),
//              let vomiting = HKObjectType.categoryType(forIdentifier: .vomiting),
//              let diarrhea = HKObjectType.categoryType(forIdentifier: .diarrhea),
//              let dizziness = HKObjectType.categoryType(forIdentifier: .dizziness),
//              let fatigue = HKObjectType.categoryType(forIdentifier: .fatigue),
//              let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
//              let headache = HKObjectType.categoryType(forIdentifier: .headache),
        //            let moodChanges = HKObjectType.categoryType(forIdentifier: .moodChanges),
        //            let sleepChanges = HKObjectType.categoryType(forIdentifier: .sleepChanges),
        //            let appetiteChanges = HKObjectType.categoryType(forIdentifier: .appetiteChanges),
//              let coughing = HKObjectType.categoryType(forIdentifier: .coughing),
//              let constipation = HKObjectType.categoryType(forIdentifier: .constipation),
//              let generalizedBodyAche = HKObjectType.categoryType(forIdentifier: .generalizedBodyAche),
//              let shortnessOfBreath = HKObjectType.categoryType(forIdentifier: .shortnessOfBreath),
//              let soreThroat = HKObjectType.categoryType(forIdentifier: .soreThroat),
//              let drySkin = HKObjectType.categoryType(forIdentifier: .drySkin)
        else {
            completion(.notAvailable)
            return
        }

        // MARK: this is important, it's the list of types we handle

        let healthKitTypesToWrite: Set<HKSampleType> = [heartRate,
                                                        oxygenSaturation,
                                                        hrv,
                                                        sleep,
                                                        respiratoryRate,
                                                        HKObjectType.workoutType()]

        let healthKitTypesToRead: Set<HKObjectType> = [heartRate,
                                                       oxygenSaturation,
                                                       hrv,
                                                       sleep,
                                                       respiratoryRate,
                                                       HKObjectType.workoutType()]

        // 4. Request Authorization

        // Present user with items we need permission for in HealthKit
        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead, completion: { (userWasShownPermissionView, error) in
            if error != nil {
                self.authorized = false
                mainDebugger.append("Error requesting authorization for healthdata: \(error?.localizedDescription ?? "unknown")", .fatalError, sourceModule: "SharedPkg Health Related requestAuthorization")
                completion(.error(error: error!))
                return
            }
            
            // Determine if the user saw the permission view
            if (userWasShownPermissionView) {
//                print("User was shown permission view")
                // ** IMPORTANT
                // Check for access to your HealthKit Type(s). This is an example of using HeartRate.
                HKObjectType.quantityType(forIdentifier: .heartRate)
                if self.healthStore.authorizationStatus(for: heartRate) == .sharingAuthorized,
                   self.healthStore.authorizationStatus(for: oxygenSaturation) == .sharingAuthorized,
                   self.healthStore.authorizationStatus(for: hrv) == .sharingAuthorized,
                   self.healthStore.authorizationStatus(for: respiratoryRate) == .sharingAuthorized,
                   self.healthStore.authorizationStatus(for: sleep) == .sharingAuthorized {
//                    print("Permission Granted to Access BodyMass")
                    self.authorized = true
                    completion(.authorized)
                } else {
                    self.authorized = false
                    completion(.denied)
//                    print("Permission Denied to Access BodyMass")
                }
            } else {
//                print("User was not shown permission view")
                self.authorized = false
                completion(.denied)
            }
        })
    }
}

public func askHealthAuthorization(healthAuthorizationManager: HealthAuthorizationProtocol) {
    healthAuthorizationManager.requestAuthorizationToReadHeartRateData { status in
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                mainDebugger.append("ok we can read/write health data")
            case .notAvailable:
                dispatchMainEvent(.HealthAuthorizationError(errorMessage: "HealthDataUnavailableErrorMsg"), "askHealthAuthorization")
                return
            case .error, .unknown, .custom:
                dispatchMainEvent(.HealthAuthorizationError(errorMessage: status.localizedDescription), "askHealthAuthorization")
                return
            case .denied:
                dispatchMainEvent(.HealthAuthorizationError(errorMessage: "HealthPermissionsNotGrantedErrorMsg"), "askHealthAuthorization")
            case .notDetermined:
                break
            }
        }
    }
}
