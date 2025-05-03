//
//  FileHelpers.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 20/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func getContentsOfDocumentsDirectory(filteredToFileType fileType: MirrorHRFileTypes? = nil) -> [String] {
    let contents = try? FileManager.default.contentsOfDirectory(atPath: getDocumentsDirectory().path)

    if let contents = contents, let fileType = fileType {
        return contents.filter { $0.hasPrefix(fileType.filePrefix) }
    }
    return contents ?? []
}
    
public enum TimeUnits: String, CaseIterable {
    case minutes = "minutesString"
    case seconds = "secondsString"
}

enum MirrorHRFileTypes: String, Codable {
    case anomalies
    case deepSleep
    case lightSleep
    case session
    case videoLog
    case seizureLog
    case notesLog
    case videoLogData
    case transcript
    case hrData
    case parameters
    case alarms
    case kid
    case patient
    case unclassified
    case json
    case allDiaryTypes

    var filePrefix: String {
        switch self {
        case .allDiaryTypes:
            return "allDiaryTypes"
        case .seizureLog:
            return "seizure."
        case .notesLog:
            return "notes."
        case .anomalies:
            return "Anomalies."
        case .deepSleep:
            return "DeepSleep."
        case .lightSleep:
            return "LightSleeps."
        case .session:
            return "session."
        case .videoLog:
            return "videolog."
        case .videoLogData:
            return "AudioVideoLogs."
        case .transcript:
            return "transcript."
        case .hrData:
            return "hrdata."
        case .parameters:
            return "Parameters."
        case .alarms:
            return "Alarms."
        case .kid:
            return "Kid."
        case .patient:
            return "Patient."
        case .json:
            return "json."
        case .unclassified:
            return "text."
        }
    }

    var fileSuffix: String {
        switch self {
        case .allDiaryTypes:
            return ".all"
        case .seizureLog:
            return ".mp4"
        case .notesLog:
            return ".json"
        case .anomalies:
            return ".json"
        case .deepSleep:
            return ".json"
        case .lightSleep:
            return ".json"
        case .session:
            return ".json"
        case .videoLog:
            return ".mp4"
        case .videoLogData:
            return ".mp4"
        case .transcript:
            return ".json"
        case .hrData:
            return ".json"
        case .parameters:
            return ".json"
        case .alarms:
            return ".json"
        case .kid:
            return ".json"
        case .patient:
            return ".json"
        case .json:
            return "json"
        case .unclassified:
            return "text"
        }
    }

    var description: String {
        switch self {
        case .allDiaryTypes: return "All"
        case .seizureLog: return "Seizure"
        case .notesLog: return "Notes"
        case .anomalies: return "Anomalies"
        case .deepSleep: return "DeepSleep"
        case .lightSleep: return "LightSleeps"
        case .session: return "session"
        case .videoLog: return "VideoLog"
        case .videoLogData: return "AudioVideoLogs"
        case .transcript: return "transcript"
        case .hrData: return "hrdata"
        case .parameters: return "Parameters"
        case .alarms: return "Alarms"
        case .kid: return "Kid"
        case .patient: return "Patient"
        case .json: return "Json file"
        case .unclassified: return "Text"
        }
    }
}
