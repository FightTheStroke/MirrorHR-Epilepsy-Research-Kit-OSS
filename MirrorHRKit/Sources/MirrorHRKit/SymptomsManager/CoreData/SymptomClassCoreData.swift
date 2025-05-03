//
//  SymptomClass.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 08/02/21.
//  Copyright 2021 FightTheStroke Foundation. All rights reserved.
//

import AVKit
import Combine
import CoreData
import Foundation
import SharedPkg
import SwiftUI
import MirrorHRTelemetryPackage

public final class SymptomLog: Equatable, Identifiable, ObservableObject {
    let symptomsManager = SymptomsManager.shared
    
    @Published var savedStatus: SavedStatus = .unSaved
    
    public var id: UUID
    var symptom: HandledSymptomsEvents
    var startDate: Date { didSet { symptomData?.startDate = startDate } }
    var endDate: Date { didSet { symptomData?.endDate = endDate } }
    var severity: Int16? { didSet { symptomData?.severity = severity ?? Int16(SymptomSeverityRanges.unspecified.value)} }
    var notes: String? { didSet { symptomData?.notes = notes } }
    var jsonMetaData: String? { didSet { symptomData?.jsonMetaData = jsonMetaData }}
    var sincePreviousLog: Double = 0 { didSet { symptomData?.sincePreviousLog = sincePreviousLog }}
    var videoFileName: String? { didSet { symptomData?.videoFileName = videoFileName }}
    var videoMetaData: String? { didSet { symptomData?.videoMetaData = videoMetaData }}
    var videoTranscript: String? { didSet { symptomData?.videoTranscript = videoTranscript }}
    var videoThumbnail: Data? { didSet { symptomData?.videoThumbnail = videoThumbnail }}
    var videoDuration: Double? { didSet { symptomData?.videoDuration = videoDuration ?? 0 }}
    var videoSentiment: Double? { didSet { symptomData?.videoSentiment = videoSentiment ?? 0 }}
    var latitude: Double? { didSet {symptomData?.latitude = latitude ?? 0}}
    var longitude: Double? { didSet {symptomData?.longitude = longitude ?? 0}}
    var patientName: String?
    
    private var videoThumbnailData: Data?
    internal var isRemoteStreaming: Bool
    
    private var symptomData: SymptomsData?
    
    public init(_ symptom: HandledSymptomsEvents,
                startDate: Date? = Date(),
                endDate: Date? = Date(),
                severity: SymptomSeverityRanges? = .unspecified,
                jsonMetaData: String? = nil,
                notes: String? = defaultQuickLogNote,
                isRemoteStreaming: Bool = false,
                latitude: Double? = nil,
                longitude: Double? = nil,
                patientName: String? = nil
    ) {
        id = UUID()
        self.startDate = startDate ?? Date()
        self.endDate = endDate ?? Date()
        self.symptom = symptom
        self.severity = Int16(severity?.value ?? SymptomSeverityRanges.unspecified.value)
        self.notes = notes
        self.isRemoteStreaming = isRemoteStreaming
        self.jsonMetaData = jsonMetaData
        self.sincePreviousLog = calcSincePreviousLog()
        self.videoFileName = symptom.isVideo ? createVideoLogName() : nil
        self.videoThumbnail = nil
        self.videoTranscript = nil
        self.videoMetaData = nil
        self.videoDuration = 0
        self.videoSentiment = 0
        self.videoMetaData = nil
        self.patientName = patientName
        if latitude == nil, longitude == nil, let location = LocationManager.shared.currentLocation {
            // if coordinates are not passed, try to get them from LocationManager
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        } else {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    func reset() {
        DispatchQueue.main.async { [self] in
            id = UUID()
            savedStatus = .unSaved
            notes = defaultQuickLogNote
            jsonMetaData = nil
            isRemoteStreaming = false
            startDate = Date()
            endDate = Date()
            severity = Int16(SymptomSeverityRanges.unspecified.value)
            sincePreviousLog = calcSincePreviousLog()
            videoFileName = symptom.isVideo ? createVideoLogName() : nil
            videoThumbnail = nil
            videoTranscript = nil
            videoMetaData = nil
            videoDuration = 0
            videoSentiment = 0
            videoMetaData = nil
            latitude = nil
            longitude = nil
            patientName = nil
        }
    }
    
    var rawValue: String {
        symptom.rawValue
    }
    
    enum SavedStatus: Equatable {
        case updated
        case updating
        case added
        case unSaved
        case isNotAVideo
        case saved
        case error(description: String)
        
        var image: String {
            switch self {
            case .unSaved:
                return "circle"
            case .updated, .saved, .added:
                return "checkmark.circle.fill"
            case .isNotAVideo:
                return "video.slash.fill"
            case .updating:
                return "pencil.circle"
            case .error:
                return "exclamationmark.triangle.fill"
            }
        }
        
        var toolTip: String {
            switch self {
            case .unSaved:
                return "saveBtnMsg".local()
            case .updated, .added, .saved:
                return "savedBtnMsg".local()
            case .updating:
                return "Updating".local()
            case .isNotAVideo:
                return "Is not a video".local()
            case .error(description: let description):
                mainDebugger.append("SymptomsQuickLogAppendView error in saving symptom \(description)")
                return "Error: \(description)".local()
            }
        }
        
        var color: Color {
            switch self {
            case .unSaved:
                return .primary
            case .updated, .added, .saved:
                return .green
            case .updating:
                return .orange
            case .isNotAVideo:
                return .brown
            case .error:
                return .red
            }
        }
    }
    
    var videoUrl: URL? {
        guard let fileName = self.videoFileName else {
            return nil
        }
        return getVideoUrl(fileName: fileName)
    }
    
    func createVideoLogName() -> String {
        let logPrefix = symptom.fileType.filePrefix
        let logExt = symptom.fileType.fileSuffix
        return logPrefix + appName + startDate.toStdString() + logExt
    }
    
    func calcVideoDuration() async -> Double {
        guard let videoUrl = self.videoUrl else {
            return 0
        }
        let asset = AVURLAsset(url: videoUrl)
        
        do {
            let duration = try await asset.load(.duration)
            return duration.seconds
        } catch {
            // Handle or log error if needed
            print("Error loading video duration: \(error)")
            return 0
        }
    }
    
    enum AnalyzeVideoError: Error {
        case unknownError
        case noURL
        case aIError(msg: String)
        case noError
    }
    
    private actor VideoAnalyzer {
        // MARK: - Analysis Results
        struct AnalysisResult: Sendable {
            let duration: Double?
            let thumbnailData: Data?
            let transcript: String?
            let sentiment: Double?
            let suggestions: String?
        }
        
        /// Analyzes video for a symptom log
        func analyze(_ symptomLog: SymptomLog) async throws -> AnalysisResult {
            // Comment: Extract values to prevent actor re-entrancy
            guard let videoURL = symptomLog.videoUrl else {
                throw NSError(domain: "VideoAnalysis",
                             code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "No video URL"])
            }
            
            // Comment: Process in isolated context
            let duration = await calcVideoDuration(for: videoURL)
            let thumbnailData = try await generateThumbnail(for: videoURL)
            
            // Comment: Use type from symptomLog to determine output
            let output = (symptomLog.symptom == .videoLog ?
                         AugumentVideoLogFlowManager.PossibleOutputs.everything :
                         AugumentVideoLogFlowManager.PossibleOutputs.transcriptOnly)
            
            // Comment: Convert callback-based API to async/await
            return try await withCheckedThrowingContinuation { continuation in
                let empowerVideoLogClass = AugumentVideoLogFlowManager(videoURL: videoURL, output: output)
                
                empowerVideoLogClass.start { status, transcript, sentiment, suggestedSymptoms in
                    switch status {
                    case .error(let msg):
                        continuation.resume(throwing: NSError(
                            domain: "VideoAnalysis",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: msg]
                        ))
                    default:
                        let result = AnalysisResult(
                            duration: duration,
                            thumbnailData: thumbnailData,
                            transcript: transcript,
                            sentiment: sentiment,
                            suggestions: suggestedSymptoms?.jsonString
                        )
                        continuation.resume(returning: result)
                    }
                }
            }
        }
        
        // Comment: Existing helper methods remain the same
        private func generateThumbnail(for videoURL: URL) async throws -> Data? {
            // Implementation remains the same
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var imageRef: CGImage?
            
            do {
                let time = CMTimeMake(value: 1, timescale: 1)
                imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                if let imageRef = imageRef {
                    return UIImage(cgImage: imageRef)
                        .jpegData(compressionQuality: 0.8)
                } else {
                    return nil
                }
            } catch {
                print("Error generating thumbnail: \(error)")
                return nil
            }
        }
        
        private func calcVideoDuration(for videoURL: URL) async -> Double {
            // Implementation remains the same
            let asset = AVURLAsset(url: videoURL)
            
            do {
                let duration = try await asset.load(.duration)
                return duration.seconds
            } catch {
                // Handle or log error if needed
                print("Error loading video duration: \(error)")
                return 0
            }
        }
    }
    
    func analizeVideo(completion: @escaping (_ done: Bool, _ error: AnalyzeVideoError?) -> Void) {
        Task {
            do {
                // Comment: Process in isolated actor
                let analyzer = VideoAnalyzer()
                let result = try await analyzer.analyze(self)
                
                // Comment: Update state on main thread
                await MainActor.run {
                    self.videoDuration = result.duration
                    self.videoThumbnail = result.thumbnailData
                    self.videoTranscript = result.transcript
                    self.videoSentiment = result.sentiment
                    self.videoMetaData = result.suggestions
                    completion(true, nil)
                }
            } catch {
                // Comment: Handle errors on main thread
                await MainActor.run {
                    mainDebugger.append("Video analysis error: \(error.localizedDescription)", .error)
                    completion(false, .aIError(msg: error.localizedDescription))
                }
            }
        }
    }
    
    func append(_ completion: @escaping (_ status: SavedStatus) -> Void) {
        symptomsManager.appendOrUpdateSymptomsLog(self) { status in
            DispatchQueue.main.async {
                self.savedStatus = status
                completion(self.savedStatus)
            }
        }
    }
    
    func saveAndAnalyzeVideoLog(_ completion: @escaping (_ status: SavedStatus) -> Void) {
        guard symptom.isVideo else {
            completion(.isNotAVideo)
            return
        }
        
        analizeVideo { done, error in
            if done {
                self.append { status in
                    completion(status)
                }
            } else {
                completion(.error(description: error.debugDescription))
                mainDebugger.append("there was an error saving the video symptom: \(String(describing: error))", .error, sourceModule: "saveAndAnalyzeVideoLog")
            }
        }
    }
    
    private func calcSincePreviousLog() -> Double {
        var interval: TimeInterval = 0
        guard let lastLog = symptomsManager.symptomsData.last?.endDate?.timeIntervalSince1970 else {
            return 0
        }
        interval = startDate.timeIntervalSince1970 - lastLog
        return interval
    }
    
    public func saveLog(timeUnit: TimeUnits, symptomLenght: Int, notes: String) {
        guard savedStatus == .unSaved || savedStatus == .updating else { return }
        
        switch timeUnit {
        case .minutes:
            endDate = startDate.addingTimeInterval(TimeInterval(symptomLenght*60))
        case .seconds:
            endDate = startDate.addingTimeInterval(TimeInterval(symptomLenght))
        }
        self.notes = notes
        // here it append the log
        append { savedStatus in
            mainDebugger.append("\(self.rawValue) \(savedStatus)")
            self.savedStatus = savedStatus
        }
    }
}

extension SymptomLog {
    public static func == (lhs: SymptomLog, rhs: SymptomLog) -> Bool {
        lhs.id == rhs.id
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension SymptomsData {
    public override var description: String {
        return "SymptomsData"
    }
}
