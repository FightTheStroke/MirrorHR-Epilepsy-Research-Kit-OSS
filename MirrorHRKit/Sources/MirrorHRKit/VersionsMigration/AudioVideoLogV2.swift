//
//  AudioVideoLogV2.swift
//  EpilepsyResearchKit2020
//
//  Created by Roberto D’Angelo on 23/03/2020.
//  Copyright © 2020 Roberto D’Angelo. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import SwiftUI
import SharedPkg

class AudioVideoLogV2: Codable { // it's codable
    var id: Int
    var transcript: String = NILSTRING
    let logPrefix: String
    var logCoreName: String = appName
    let logExt: String
    var filename: String
    var fileType: MirrorHRFileTypes
    var userID: String = ProfileGenericSettings.shared.kidName
    var save2Cloud: Bool
    var cloudPath: String
    var date: String
    var NLPMetaData: [AudioVideoMetadata]
    var videoDataFullFileName: String = NILSTRING
    var dateLog: Date {
        Date.fromStdDateString(date) ?? Date()
    }
    var url: URL? {
        getVideoUrl(fileName: filename)
    }
    var videoDataFileName: String {
        MirrorHRFileTypes.videoLogData.filePrefix + filename
    }
    var nLPMetaData2JsonString: String {
        do {
            let jsonData = try encoder.encode(NLPMetaData)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            mainDebugger.append("can't encode jsonstring", .error, sourceModule: "AudioVideoLogV2 nLPMetaData2JsonString")
            return ""
        }
    }
    
    init(fileType: MirrorHRFileTypes, save2Cloud: Bool? = false) {
        let now = Date()
        logPrefix = fileType.filePrefix
        logExt = fileType.fileSuffix
        id = -1 // create new ID but it will be associated only when the file is added to the real queue
        filename = logPrefix + logCoreName + userID + now.toStdString() + logExt
        self.save2Cloud = save2Cloud ?? false
        date = now.toStdString()
        cloudPath = "\(userID)/\(fileType.filePrefix)\(now.returnCloudPathForML())\(filename)"
        self.fileType = fileType
        NLPMetaData = []
    }
    
    static func loadAudioVideoMetaDataArrayFromJson(jsonString: String) -> [AudioVideoMetadata]? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode([AudioVideoMetadata].self, from: data)
    }
    
    func saveVideoData(videoData: Data) {
        do {
            try videoData.write(to: url!, options: .atomic)
            mainDebugger.append("File saved on  \(String(describing: url))")
        } catch {
            mainDebugger.append("I'm sorry I was not able to save the Data :( - Error: \(error)", .error, sourceModule: "AudioVideoLogV2 saveVideoData")
        }
    }

    func jsonString() -> String {
        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            mainDebugger.append("can't encode jsonstring", .error, sourceModule: "AudioVideoLogV2 jsonString")
            return ""
        }
    }
}
