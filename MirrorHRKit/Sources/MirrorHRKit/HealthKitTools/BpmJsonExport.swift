//
//  BpmJsonExport.swift
//  
//
//  Created by Roberto D’Angelo on 09/08/22.
//

import Foundation
import HealthKit
import SwiftUI
import SharedPkg

extension ReadHealthData {
    public static func heartRateJsonExport(userID: String, fileName: String, ext: String = ".json", startDate: Date, endDate: Date,  completion: @escaping (Result<URL, Error>) -> Void) {
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let heartRateUnit = HKUnit(from: "count/min")
        let fullFileName = fileName + ext
        
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
        var jsonstring: String = openGraph + apix + mainBrand + apix + colon + openGraph
        jsonstring += apix + userIDString + apix + colon + apix + userID + apix + comma
        jsonstring += apix + typeString + apix + colon + apix + typeValue + apix + comma
        jsonstring += apix + bpmExportMain + apix + colon + openSquare
        
//        print(jsonstring)
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
                mainDebugger.append(Errors.noData.debugDescription, .error, sourceModule: "heartRateJsonExport")
                completion(.failure(Errors.noData.error))
                return
            }
            DispatchQueue.main.async {
                for sample in samples {
                    let date: Date = sample.startDate
                    let bpm: Double = sample.quantity.doubleValue(for: heartRateUnit)
                    jsonstring += openGraph + apix + dayString + apix + colon + date.toDayMonthYear() + apix + comma
                    jsonstring += apix + timeString + apix + colon + date.toPreciseTime() + apix + comma
                    jsonstring += apix + bpmString + apix + colon + "\(Int(bpm))" + apix
                    jsonstring += closeGraph + comma
                }
                jsonstring.removeLast() // remove last comma
                jsonstring += closeSquare + closeGraph + closeGraph // closing json structure

//                print(jsonstring)

                let result = saveJsonFile(jsonString: jsonstring, fullFileName: fullFileName)
                switch result {
                case .failure(let error):
                    mainDebugger.append("Failed to create Json file: \(error)", .error, sourceModule: "heartRateJsonExport")
                    completion(.failure(error))
                case .success(let fileURL):
                    mainDebugger.append("BPM JSon exported to \(fullFileName)")
                    completion(.success(fileURL))
                }
            }
        }
        healthStore.execute(heartRateQuery)
    }
    
    internal static func saveJsonFile(jsonString: String, fullFileName: String, overwrite: Bool = true) -> Result<URL, Error> {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent(fullFileName)
            do {
                if overwrite {
                    try FileManager.default.removeItem(at: pathWithFilename)
                }
                try jsonString.write(to: pathWithFilename,
                                     atomically: true,
                                     encoding: .utf8)
            } catch {
                return .failure(error)
            }
            return .success(pathWithFilename)
        } else {
            return .failure(NSError(domain: "ReadHealthData", code: 1200, userInfo: ["error": "can't find the file"]))
        }
    }
}
