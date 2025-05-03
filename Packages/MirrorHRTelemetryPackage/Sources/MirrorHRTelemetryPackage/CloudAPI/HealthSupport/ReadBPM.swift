//
//  ReadBPM.swift
//  
//
//  Created by Roberto D’Angelo on 09/08/22.
//

import Foundation
import HealthKit

extension CloudAPIManager {
    internal static let healthAuthorizationManager: HealthAuthorizationProtocol = HealthAuthorizationManager()
    internal static let healthStore = HKHealthStore()
    
    public func sendBPMFromHealthAsJson(startDate: Date, endDate: Date, completion: @escaping (Result<CloudAPIResponse?, Error>) -> Void) {
        let userID = TelemetryHeader.shared.currentUserID
        let defaultFileName = "bpmJsonFile"
        heartRateJsonExport(userID: userID, fileName: defaultFileName, startDate: startDate, endDate: endDate) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let filePath):
                self.sendFile(fileURL: URL(fileURLWithPath: filePath)) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let cloudResponse):
                        completion(.success(cloudResponse))
                    }
                }
            }
        }
    }
    
    public func heartRateJsonExport(userID: String, fileName: String, ext: String = ".json", startDate: Date, endDate: Date, completion: @escaping (Result<String, Error>) -> Void) {
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let heartRateUnit = HKUnit(from: "count/min")
        let fullFileName = fileName + ext
        
        CloudAPIManager.healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            guard error == nil, success == true else {
                debugLog("Can't have authorization to read BPM HealthData")
                completion(.failure(error!))
                return
            }
        }
        
        let newLine = "\n"
        let apix = "\""
        let colon = ":"
        let comma = ","
        let openGraph = "{"
        let closeGraph = "}"
        let openSquare = "["
        let closeSquare = "]"
        let mainBrand = "MirrorHR"
        let userIDString = "userID"
        let typeString = "type"
        let typeValue = fileName
        let bpmExportMain = "bpmExport"
        let dayString = "Day"
        let timeString = "Time"
        let bpmString = "BPM"
        
        // opening json structure with header info
        var jsonstring: String = openGraph + newLine + apix + mainBrand + apix + colon + openGraph
        jsonstring += newLine + apix + userIDString + apix + colon + apix + userID + apix + comma
        jsonstring += apix + typeString + apix + colon + apix + typeValue + apix + comma
        jsonstring += apix + bpmExportMain + apix + colon + openSquare + newLine
        
        // Sample JsonString Struct
        //        {
        //          "MirrorHR" : {
        //            "userID": "ABCD",
        //            "type": "RealTimeSession",
        //            "bpmExport": [
        //              {
        //              "Day": "08-08-2022",
        //              "Time": "12:08:29.506",
        //              "bpm": "192"
        //              },
        //              {
        //              "Day": "08-08-2022",
        //              "Time": "12:08:29.506",
        //              "bpm": "192"
        //              },
        //              {
        //              "Day": "08-08-2022",
        //              "Time": "12:08:29.506",
        //              "bpm": "192"
        //              }
        //            ]
        //          }
        //        }
        
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                           predicate: predicate, limit: HKObjectQueryNoLimit,
                                           sortDescriptors: sortDescriptors) { _, results, _ in
            guard let samples = results as? [HKQuantitySample] else {
                let error = Errors.noHealthDataFound
                debugLog(error.description)
                completion(.failure(error.error))
                return
            }
            if !samples.isEmpty {
                for sample in samples {
                    let date: Date = sample.startDate
                    let bpm: Double = sample.quantity.doubleValue(for: heartRateUnit)
                    jsonstring += openGraph + newLine + apix + dayString
                    jsonstring += apix + colon + apix + date.toDayMonthYear() + apix + comma + newLine
                    jsonstring += apix + timeString + apix + colon
                    jsonstring += apix + date.toPreciseTime() + apix + comma + newLine
                    jsonstring += apix + bpmString + apix + colon + apix + "\(Int(bpm))" + apix
                    jsonstring += newLine + closeGraph + comma + newLine
                }
                jsonstring.removeLast(2) // remove last \n and comma
            }
            jsonstring += newLine + closeSquare + newLine + closeGraph + newLine + closeGraph // closing json structure
            
            let result = self.saveJsonFile(jsonString: jsonstring, fullFileName: fullFileName)
            switch result {
            case .failure(let error):
                debugLog("Failed to create Json file: \(error)")
                completion(.failure(error))
            case .success(let filePath):
                debugLog("BPM JSon exported to \(fullFileName)")
                completion(.success(filePath))
            }
        }
        CloudAPIManager.healthStore.execute(heartRateQuery)
    }
}
