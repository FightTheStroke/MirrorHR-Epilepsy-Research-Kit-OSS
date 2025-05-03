//
//  SaveJsonFile.swift
//  
//
//  Created by Roberto D’Angelo on 11/09/22.
//

import Foundation
import SharedPkg

func saveJsonFile(jsonString: String, fullFileName: String) -> Result<String, Error> {
    let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let filePath = documentDirectoryPath.appendingPathComponent(fullFileName)
    let cleanJsonString = jsonString.replacingOccurrences(of: "\\", with: "")
    
    removeFile(filePath: filePath)
    do {
        try cleanJsonString.write(toFile: filePath, atomically: true, encoding: .utf8)
    } catch {
        mainDebugger.append(error.localizedDescription, .error, sourceModule: "SharedPkg - saveJsonFile - write jsonString")
        return .failure(error)
    }
    return .success(filePath)
}

func removeFile(filePath: String) {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath) {
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch {
            mainDebugger.append(error.localizedDescription, .error, sourceModule: "CloudAPIManager - removeFile at \(filePath)")
        }
    }
}
