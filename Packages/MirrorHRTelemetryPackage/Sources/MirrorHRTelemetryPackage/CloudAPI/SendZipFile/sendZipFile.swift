//
//  SendZipFile.swift
//  
//
//  Created by Roberto D’Angelo on 19/09/22.
//

import Foundation
import ZIPFoundation
import Alamofire
import RoberdanSecretsPackage

extension CloudAPIManager {
    func sendTelemetrySession(_ jsonString: String) async {
        
#if DEBUG
        return // stop sending telemetry data when in debug
#else
        // 1. set the stage
        let cleanJsonString = jsonString.replacingOccurrences(of: "\\", with: "")
        let fileName: String = "TelemetryJsonFileV3"
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let jsonFileString = documentDirectoryPath.appendingPathComponent(fileName + ".json")
        let zipFileString = documentDirectoryPath.appendingPathComponent(fileName + ".zip")
        
        let fileManager = FileManager()
        let jsonFileURL = URL(fileURLWithPath: jsonFileString)
        let zipFileURL = URL(fileURLWithPath: zipFileString)
        let headers: HTTPHeaders = ["Content-Type": "application/zip", "Content-Encoding": "deflate", RoberdanSecretsPackage.headerKey: RoberdanSecretsPackage.headerKeyValue]

        // 2. remove the old file it they exists
        try? fileManager.removeItem(at: jsonFileURL) // first remove the old Json file
        try? fileManager.removeItem(at: zipFileURL) // thern remove the old zip file
        
        // 3. save the json file then save the zip file
        do {
            try cleanJsonString.write(to: jsonFileURL, atomically: true, encoding: .utf8) // then write the new file
            try fileManager.zipItem(at: jsonFileURL, to: zipFileURL, compressionMethod: .deflate) // then zip it
        } catch {
            debugLog(error.localizedDescription, isImportant: true, module: "CloudAPIManager - sendTelemetrySession saving files")
            return
        }

        // 4. send the message in the file zipFileString if it's valid, via AlamoFire
        guard zipFileString != "" else {
            debugLog(CloudAPIManager.Errors.emptyFilePath.description, isImportant: true, module: "CloudAPIManager - sendTelemetrySession")
            return
        }
        AF.upload(multipartFormData: { multipartdata in
            multipartdata.append(zipFileURL, withName: "files")
        }, to: RoberdanSecretsPackage.hostPostJsonFile, headers: headers)
        .responseData { response in
            guard let statusCode = response.response?.statusCode, statusCode == successStatusCode else {
                let error = Errors.wrongStatusCode(code: response.response?.statusCode)
                debugLog("CloudAPIManager: Error in Sending File to CloudAPI - \(error)", isImportant: false, module: "CloudAPIManager sendTelemetrySession")
                return
            }
            debugLog("CloudAPIManager: succesfully sent File to the cloud")
        }

        // 5. remove the original files
        do {
            try fileManager.removeItem(at: jsonFileURL) // then remove the new Json file and leave only the .zip
            try fileManager.removeItem(at: zipFileURL)
        } catch {
            debugLog(error.localizedDescription, isImportant: true, module: "CloudAPIManager - sendTelemetrySession")
            return
        }
#endif
    }
}
