//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 08/08/22.
//

import Foundation
import Alamofire

public struct CloudAPIResponse: Codable, Equatable {
    internal var result: Results = .noResponseYet
    internal var response: String?
    
    // Possible resulsts strings from API
    internal enum Results: String, Codable {
        case success = "Success"
        case failure = "Failure"
        case noResponseYet = "No response yet"
    }
    
    internal func jsonString() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "CloudAPIResponse - jsonString")
            return ""
        }
    }
    
    public func toDictionary() -> Parameters? {
        var dictionary: Parameters?
        do {
            let jsonData = try JSONEncoder().encode(self)
            dictionary = try JSONSerialization.jsonObject(with: jsonData) as? Parameters
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "CloudAPIResponse - toDictionary")
        }
       return dictionary
    }
    
    public static func loadFromJson(jsonString: String) -> CloudAPIResponse? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(CloudAPIResponse.self, from: data)
    }
    
    public static func loadFromData(data: Data) -> CloudAPIResponse? {
        var newResponse: CloudAPIResponse?
        do {
            newResponse = try JSONDecoder().decode(CloudAPIResponse.self, from: data)
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "CloudAPIResponse - loadFromData")
        }
        return newResponse
    }
}

public struct CloudAPIGETResponse: Codable, Equatable {
    internal var MessagesSent: Int = 0
    internal var MessagesConfirmed: Int = 0
    internal var UpTime: String = ""
    internal var RefreshTime: String = ""
    
    internal func jsonString() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "CloudAPIGETResponse - jsonString")
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> CloudAPIGETResponse? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(CloudAPIGETResponse.self, from: data)
    }
    
    public static func loadFromData(data: Data) -> CloudAPIGETResponse? {
        var newResponse: CloudAPIGETResponse?
        do {
            newResponse = try JSONDecoder().decode(CloudAPIGETResponse.self, from: data)
        } catch {
            debugLog(error.localizedDescription, isImportant: false, module: "CloudAPIGETResponse - loadFromData")
        }
        return newResponse
    }
}
