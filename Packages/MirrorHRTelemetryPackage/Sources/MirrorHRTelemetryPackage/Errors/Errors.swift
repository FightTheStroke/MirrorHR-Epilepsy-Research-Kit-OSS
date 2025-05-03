//
//  Errors.swift
//  
//
//  Created by Roberto D’Angelo on 08/08/22.
//

import Foundation

extension CloudAPIManager {
    public enum Errors {
        case inIdleStatus
        case wrongMessageFormat
        case invalidJsonFormat
        case fileNotFound
        case noHealthDataFound
        case wrongCloudAPIResponseFormat
        case wrongStatusCode(code: Int?)
        case emptyResponse
        case emptyFilePath
        case errorInZipping
        case errorInDeletingFile
        
        public var description: String {
            switch self {
            case .invalidJsonFormat:
                return "Invalid JSON format"
            case .errorInDeletingFile:
                return "Error in deleting file"
            case .errorInZipping:
                return "Error in compressing the data"
            case .wrongMessageFormat:
                return "Message is in the wrong format"
            case .inIdleStatus:
                return "It's just in idle, waiting. It's not a proper error"
            case .fileNotFound:
                return "SendFile Error: File Not Found"
            case .noHealthDataFound:
                return "No Health Data found for json export"
            case .wrongCloudAPIResponseFormat:
                return "CloudAPI Response was in the wrong format"
            case .wrongStatusCode(let code):
                return "CloudAPI Response status code was error \(code ?? 0)"
            case .emptyResponse:
                return "CloudAPI send an empty response"
            case .emptyFilePath:
                return "Received filePath was empty"
            }
        }
        
        public var error: Error {
            switch self {
            case .invalidJsonFormat:
                return NSError(domain: "CloudAPIManager", code: 1099, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .wrongMessageFormat:
                return NSError(domain: "CloudAPIManager", code: 1100, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .inIdleStatus:
                return NSError(domain: "CloudAPIManager", code: 1101, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .fileNotFound:
                return NSError(domain: "CloudAPIManager", code: 1102, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .noHealthDataFound:
                return NSError(domain: "CloudAPIManager", code: 1103, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .wrongCloudAPIResponseFormat:
                return NSError(domain: "CloudAPIManager", code: 1104, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .wrongStatusCode:
                return NSError(domain: "CloudAPIManager", code: 1105, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .emptyResponse:
                return NSError(domain: "CloudAPIManager", code: 1106, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .emptyFilePath:
                return NSError(domain: "CloudAPIManager", code: 1107, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .errorInZipping:
                return NSError(domain: "CloudAPIManager", code: 1108, userInfo: [NSLocalizedDescriptionKey: self.description])
            case .errorInDeletingFile:
                return NSError(domain: "CloudAPIManager", code: 1109, userInfo: [NSLocalizedDescriptionKey: self.description])
            }
        }
    }
}
