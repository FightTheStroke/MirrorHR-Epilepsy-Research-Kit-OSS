//
//  AudioVideoLogV1.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 19/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg

class AudioVideoLogV1: Codable { // it's codable
    var id: Int
    var transcript: String = NILSTRING
    let logPrefix: String
    var logCoreName: String = appName
    let logExt: String
    var filename: String
    var fileType: MirrorHRFileTypes
    var userID: String
    var save2Cloud: Bool
    var cloudPath: String
    var date: String
    var videoDataFullFileName: String = NILSTRING
    var dateLog: Date {
        Date.fromStdDateString(date) ?? Date()
    }

    var url: URL {
        getDocumentsDirectory().appendingPathComponent(filename)
    }
    
    var videoDataFileName: String {
        MirrorHRFileTypes.videoLogData.filePrefix + filename
    }
    
    init(userID: String, fileType: MirrorHRFileTypes, save2Cloud: Bool) {
        logPrefix = fileType.filePrefix
        logExt = fileType.fileSuffix
        id = -1 // create new ID but it will be associated only when the file is added to the real queue
        filename = logPrefix + logCoreName + userID + Date().toStdString() + logExt
        self.save2Cloud = save2Cloud
        self.userID = userID
        date = Date().toStdString()
        cloudPath = "\(userID)/\(fileType.filePrefix)\(Date().returnCloudPathForML())\(filename)"
        self.fileType = fileType
    }

    func saveVideoData(videoData: Data) {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            try videoData.write(to: url, options: .atomic)
            mainDebugger.append("File saved on  \(String(describing: url))")
            if jsonString() != NILSTRING {
                // STORING THE new AV Log into files and cloud
                let videoDataFile = MyFile(content: jsonString(),
                                           userID: userID,
                                           filename: videoDataFileName,
                                           ext: "json",
                                           fileType: .videoLogData)
                videoDataFullFileName = videoDataFile.localFileName
                if !videoDataFile.save() {
                    mainDebugger.append("I'm sorry I was not able to save the file associated to audiovideolog", .error, sourceModule: "AudioVideoLogV1 SaveVideoData")
                } else {
                    mainDebugger.append("videolog associated data file saved as \(videoDataFile.filename)", .greenFlag)
                }
            }
        } catch {
            mainDebugger.append("I'm sorry I was not able to save the Data :( - Error: \(error)", .error, sourceModule: "AudioVideoLogV1 SaveVideoData catch")
        }
    }

    func jsonString() -> String {
        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            mainDebugger.append("can't encode jsonstring", .error, sourceModule: "AudioVideoLogV1 jsonString")
            return ""
        }
    }
}
