//
//  MigratorClass.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 19/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//
import AVFoundation
import AVKit
import Foundation
import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

class Migrator {
    var fromVersion: String = "0"
    var fromRelease: String = "0"
    var fromBuild: String = "0"
    var fromAllUp: String = "0"
    var toVersion: String = VERSION
    var toBuild: String = BUILDNUMBER
    var toAllUp: String = appVersion
    var error: Error?
    var migrationStatus: MigrationStatus = .notStarted
    
    enum MigrationStatus {
        case notStarted
        case done
        case notNeeded
        case withErrors(error: Error)
    }
    
    init(from: String) {
        self.fromAllUp = from
        let fromComponents = from.components(separatedBy: versionSeparator)
        if fromComponents.count == 3 { // es: 8.4.12
            fromVersion = fromComponents[0]
            fromRelease = fromComponents[1]
            fromBuild = fromComponents[2]
        }
    }
    
    func migrate(completion: @escaping (_ migrationStatus: MigrationStatus) -> Void) {
        if fromAllUp == "8.4.38" || fromAllUp == "" {
            DispatchQueue.background { [self] in
                migratePastVideos()
            } completion: {
                if self.error != nil {
                    self.migrationStatus = .withErrors(error: self.error!)
                } else {
                    self.migrationStatus = .done
                }
                completion(self.migrationStatus)
            }
        }
    }
    
    private func migratePastVideos() {
        for filename in getContentsOfDocumentsDirectory(filteredToFileType: MirrorHRFileTypes.videoLogData) {
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            if let videoLogData = FileManager.default.contents(atPath: url.path) {
                do {
                    let av2 = try JSONDecoder().decode(AudioVideoLogV2.self, from: videoLogData)
                    migrateAudioVideoLog2ToCoreData(av2)
                    mainDebugger.append("videolog migrated \(av2.filename)", .justALog)
                    try FileManager.default.removeItem(at: url as URL)
                } catch {
                    // it's probably a version 1 of the AudioVideoLog structure, without NLP MetaData
                    do {
                        let logDataV1 = try JSONDecoder().decode(AudioVideoLogV1.self, from: videoLogData)
                        let av2 = migrateFromAudioVideoLogV1toV2(logDataV1)
                        migrateAudioVideoLog2ToCoreData(av2)
                        mainDebugger.append("old format videolog found and migrated: \(logDataV1.filename)", .justALog)
                    } catch {
                        self.error = error
                        mainDebugger.append(error.localizedDescription, .error, sourceModule: "migratePastVideos")
                    }
                }
            }
        }
    }
    
    private func migrateFromAudioVideoLogV1toV2(_ avLogV1: AudioVideoLogV1) -> AudioVideoLogV2 {
        let migratedVersion: AudioVideoLogV2 = .init(fileType: avLogV1.fileType)
        migratedVersion.date = avLogV1.date
        migratedVersion.id = avLogV1.id
        migratedVersion.transcript = avLogV1.transcript
        migratedVersion.logCoreName = avLogV1.logCoreName
        migratedVersion.filename = avLogV1.filename
        migratedVersion.fileType = avLogV1.fileType
        migratedVersion.cloudPath = avLogV1.cloudPath
        migratedVersion.videoDataFullFileName = avLogV1.videoDataFullFileName
        return migratedVersion
    }
    
    fileprivate func migrateAudioVideoLog2ToCoreData(_ av2: AudioVideoLogV2) {
        if av2.fileType == .videoLog {
            SymptomsManager.shared.appendSymptomLog(.init(.videoLog, startDate: av2.dateLog, notes: av2.transcript))
        }
        if av2.fileType == .seizureLog {
            SymptomsManager.shared.appendSymptomLog(.init(.videoSeizureLog, startDate: av2.dateLog, severity: .severe, notes: av2.transcript))
        }
    }
}
