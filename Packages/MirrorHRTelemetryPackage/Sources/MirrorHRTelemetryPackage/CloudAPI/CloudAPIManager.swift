//
//  APIURL.swift
//  
//
//  Created by Roberto D’Angelo on 08/08/22.
//

import Foundation
import SwiftUI
import Alamofire
import RoberdanSecretsPackage

public final class CloudAPIManager {
    public init() {
    }
    
    public func sendMessageAsJson(_ message: TelemetryMessage, completion: @escaping (Result<CloudAPIResponse?, Error>) -> Void) {
        let params = message.toDictionary()
        
        // Verifica se il dizionario è vuoto o non valido
        guard !params.isEmpty else {
            debugLog("CloudAPIManager: Error in sending Telemetry to CloudAPI, can't convert to dictionary", isImportant: true, module: "CloudAPIManager sendMessageAsJson")
            let error: Error = Errors.wrongMessageFormat.error
            completion(.failure(error))
            return
        }

        // Validazione dell'oggetto JSON
        if !JSONSerialization.isValidJSONObject(params) {
            debugLog("CloudAPIManager: Error in sending Telemetry to CloudAPI, invalid JSON format", isImportant: true, module: "CloudAPIManager sendMessageAsJson")
            let error: Error = Errors.invalidJsonFormat.error
            completion(.failure(error))
            return
        }

        let headers: HTTPHeaders = [RoberdanSecretsPackage.headerKey: RoberdanSecretsPackage.headerKeyValue]
        AF.request(RoberdanSecretsPackage.hostJsonPost, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                guard let statusCode = response.response?.statusCode, statusCode == successStatusCode else {
                    let error = Errors.wrongStatusCode(code: response.response?.statusCode)
                    debugLog("CloudAPIManager: Error in sending message to CloudAPI - \(error)", isImportant: false, module: "CloudAPIManager sendMessageAsJson")
                    completion(.failure(error.error))
                    return
                }
                debugLog("CloudAPIManager: Successfully sent data to the cloud")
                completion(.success(CloudAPIResponse(result: .success)))
            }
    }
    
    public func sendMessageAsFile(_ message: TelemetryMessage, completion: @escaping (Result<CloudAPIResponse?, Error>) -> Void) {
        let fullFileName = "TelemetryJsonFileV2.json"
        // 1. Save the file
        let result = saveJsonFile(jsonString: message.jsonString(), fullFileName: fullFileName)
        switch result {
        case .failure(let error):
            debugLog("Failed to create Json file: \(error)")
            completion(.failure(error))
        case .success(let filePath):
            debugLog("JSonFile saved to \(fullFileName)")
            // 2: send the file
            debugLog("sendMessageAsFile - sending file: \(filePath)")
            self.sendFile(fileURL: URL(fileURLWithPath: filePath)) { result in
                // 3: remove the file and complete
                self.removeFile(filePath: filePath)
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let cloudResponse):
                    completion(.success(cloudResponse))
                }
            }
        }
    }
    
    // MARK: here it sends messages as files
    public func sendMessageAsFile(_ filePath: String, completion: @escaping (Result<CloudAPIResponse?, Error>) -> Void) {
        guard filePath != "" else {
            completion(.failure(CloudAPIManager.Errors.emptyFilePath.error))
            return
        }
        
        self.sendFile(fileURL: URL(fileURLWithPath: filePath)) { result in
            // 3: remove the file and complete
            self.removeFile(filePath: filePath)
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let cloudResponse):
                completion(.success(cloudResponse))
            }
        }
    }
    
    public func get(params: Parameters = ["param": "test params string as if it was Antani"], completion: @escaping (Result<CloudAPIGETResponse?, Error>) -> Void) {
        let headers: HTTPHeaders = [RoberdanSecretsPackage.headerKey: RoberdanSecretsPackage.headerKeyValue]
        AF.request(RoberdanSecretsPackage.hostGet, method: .get, parameters: params, headers: headers)
            .responseString { response in
                guard let result = response.value else {
                    let error = Errors.emptyResponse
                    debugLog("CloudAPIManager: Error get - \(error)", isImportant: true, module: "CloudAPIManager get")
                    completion(.failure(error.error))
                    return
                }
                completion(.success(CloudAPIGETResponse.loadFromJson(jsonString: result)))
            }
    }
}

extension CloudAPIManager {
    internal func sendFile(fileURL: URL, completion: @escaping (Result<CloudAPIResponse?, Error>) -> Void) {
        let headers: HTTPHeaders = [RoberdanSecretsPackage.headerKey: RoberdanSecretsPackage.headerKeyValue]
        
        AF.upload(multipartFormData: { multipartdata in
            multipartdata.append(fileURL, withName: "files")
        }, to: RoberdanSecretsPackage.hostPostJsonFile, headers: headers)
        .responseData { response in
            guard let statusCode = response.response?.statusCode, statusCode == successStatusCode else {
                let error = Errors.wrongStatusCode(code: response.response?.statusCode)
                debugLog("CloudAPIManager: Error in Sending File to CloudAPI - \(error)", isImportant: false, module: "CloudAPIManager sendFile")
                completion(.failure(error.error))
                return
            }
            debugLog("CloudAPIManager: succesfully sent File to the cloud")
            completion(.success(CloudAPIResponse(result: .success)))
        }
    }
    
    internal func removeFile(filePath: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch {
                debugLog(error.localizedDescription, isImportant: true, module: "CloudAPIManager - removeFile at \(filePath)")
            }
        }
    }
    
    internal func saveJsonFile(jsonString: String, fullFileName: String) -> Result<String, Error> {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let filePath = documentDirectoryPath.appendingPathComponent(fullFileName)
        let cleanJsonString = jsonString.replacingOccurrences(of: "\\", with: "")
        
        removeFile(filePath: filePath)
        do {
            try cleanJsonString.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "CloudAPIManager - saveJsonFile - write jsonString")
            return .failure(error)
        }
        return .success(filePath)
    }
}

extension CloudAPIManager {
    public func sendTestFile(fileModuleName: String, ext: String = "json", completion: @escaping (Result<CloudAPIResponse?, Error>) -> Void) {
        guard let fileURL = Bundle.module.url(forResource: fileModuleName, withExtension: ext) else {
            let error: Errors = .fileNotFound
            debugLog(error.description)
            return
        }
        let headers: HTTPHeaders = [RoberdanSecretsPackage.headerKey: RoberdanSecretsPackage.headerKeyValue]

        AF.upload(multipartFormData: { multipartdata in
            multipartdata.append(fileURL, withName: "files")
        }, to: RoberdanSecretsPackage.hostPostJsonFile, headers: headers)
        .responseData { response in
            guard let statusCode = response.response?.statusCode,
                  statusCode == successStatusCode else {
                let error = Errors.wrongStatusCode(code: response.response?.statusCode)
                debugLog("CloudAPIManager: Error in test file to CloudAPI - \(error)", isImportant: false, module: "CloudAPIManager sendTestFile")
                completion(.failure(error.error))
                return
            }
            debugLog("CloudAPIManager: succesfully sent file to the cloud")
            completion(.success(CloudAPIResponse(result: .success)))
        }
    }
}
