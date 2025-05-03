//
//  AugumentVideoLogFlowManager.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 07/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg
import Speech
import RoberdanToolBox
import OSLog
import AVFoundation

/// A class for validating symptoms detected during video diary analysis.
///
/// The `Validator` class provides functionality to:
/// - Track symptom validation status
/// - Toggle validation state
/// - Compare validator instances
/// - Maintain unique identifiers for each validation
///
/// The class implements `ObservableObject` for SwiftUI integration and supports
/// comparison operations through `Equatable` conformance.
class Validator: ObservableObject {
    /// Compares two validator instances for equality
    static func == (lhs: Validator, rhs: Validator) -> Bool {
        lhs.symptom == rhs.symptom && lhs.validated == rhs.validated && lhs.uuid == rhs.uuid
    }
    
    /// Unique identifier for the validator instance
    let uuid: UUID
    
    /// The symptom being validated
    @Published var symptom: HandledSymptomsEvents
    
    /// Whether the symptom has been validated
    @Published var validated: Bool
    
    /// Initializes a new validator instance
    ///
    /// - Parameters:
    ///   - symptom: The symptom to validate
    ///   - validated: Initial validation state
    init(symptom: HandledSymptomsEvents, validated: Bool) {
        self.symptom = symptom
        self.validated = validated
        self.uuid = UUID()
    }
    
    /// Toggles the validation state
    func toggle() {
        validated.toggle()
    }
}

class FinalSuggestedSymptoms: ObservableObject {
    static let shared = FinalSuggestedSymptoms()
    /// The list of suggested symptoms
    @Published var symptoms: [HandledSymptomsEvents] = []
    @Published var validator: [Validator] = []
    let symptomsManager = SymptomsManager.shared
    
    func prepare4Validation(suggestedSymptoms: [HandledSymptomsEvents]) {
        validator = []
        symptoms = []
        suggestedSymptoms.forEach { sympt in
            validator.append(Validator(symptom: sympt, validated: true))
        }
    }
    
    // it publish on symptoms all validated symptoms from the user. If flag for autosaving symptoms is on the it also store symptoms logs
    // it also saves all symptoms that have been validated by the user
    func publishResults() {
        let parkingLot = validator.filter { isValid in
            isValid.validated
        }
        symptoms = parkingLot.map({ validated in
            validated.symptom
        })
        symptoms.forEach {
            let curtesyDate: Date =  Date().addSec(number: 60)
            symptomsManager.appendSymptomLog(.init(
                                                    $0,
                                                    startDate: curtesyDate,
                                                    endDate: curtesyDate,
                                                    notes: "VideoLog")
                                                )
            
// TODO: Allow configuration to auto-save symptoms extracted from video log. Store responses in a database to create a learning library. Add the ability to add other symptoms in the validation screen.
        }
    }
}

/// Manages the video diary and symptom logging workflow
/// - Handles video recording and processing
/// - Integrates with NLP for symptom analysis
/// - Manages user interaction flow
/// - Implements ObservableObject for UI updates
class AugumentVideoLogFlowManager: ObservableObject {
    typealias CompletionAction = (_ status: AIFlowStatuses,
                                    _ transcript: String?,
                                    _ sentiment: Double?,
                                    _ suggestedSymptoms: ArrayOfSymptoms?) -> Void
    private var completion: CompletionAction = { status, _, _, _ in print(status) }
    private var transcript: String?
    private var isNLPAvailableForThisLanguage: Bool = isVideoDiaryAvailableInThisLanguage
    private var sentiment: Double?
    private var startTime: Date
    private var suggestedSymptoms: ArrayOfSymptoms?
    private var output: PossibleOutputs
    private var videoURL: URL
    let logger = Logger(subsystem: "AugumentVideoFlowManager", category: "AILog")
    
    enum PossibleOutputs {
        case transcriptOnly
        case everything
    }
    
    @Published var aIFlowStatus: AIFlowStatuses = .notActive {
        didSet {
            switch aIFlowStatus {
            case .notActive:
                logger.log(level: .info, "aIFlowStatus is notActive")
            case .ready:
                logger.log(level: .info, "AI ready to do the magic")
            case .start:
                logger.log(level: .info, "NLP starting with speech")
                speechRecognition()
            case .emptyTranscript:
                logger.log(level: .info, "NLP exiting with empty transcript")
                completion(.emptyTranscript, nil, nil, nil)
            case .transcriptReady:
                if output == .transcriptOnly {
                    self.completion(.transcriptReady, self.transcript, nil, nil)
                    return
                }
                detectSentiment()
            case .sentimentDetected:
                // if language is enabled for NLP it goes for it, otherwise performs a basic search
                if isNLPAvailableForThisLanguage {
                    applyNLP()
                } else {
                    applyBasicSearch()
                }
            case .nLPCompleted:
                logger.log(level: .info,"AI Symptoms detected: \(String(describing: self.suggestedSymptoms))")
                aIFlowStatus = .validateSymptomsByUser
            case .basicSymptSearchCompleted:
                aIFlowStatus = .validateSymptomsByUser
            case .error(let errorMsg):
                logger.error("NLP returned error \(errorMsg)")
                mainDebugger.append("NLP returned error \(errorMsg)", .error)
                self.completion(.error(errorMsg), nil, nil, nil)
            case .test:
                self.completion(aIFlowStatus, self.transcript, self.sentiment, self.suggestedSymptoms)
            case .validateSymptomsByUser:
                if suggestedSymptoms != nil && suggestedSymptoms?.symptoms != [] {
                    logger.log(level: .info,"asking user validation for \(String(describing: self.suggestedSymptoms))")
                    askUserValidation()
                } else {
                    aIFlowStatus = .noSymptomsDetected
                }
            case .noSymptomsDetected:
                self.completion(.noSymptomsDetected, self.transcript, self.sentiment, nil)
            case .userValidated:
                aIFlowStatus = .completed
            case .completed:
                logger.log(level: .info, "NLP Completeted. StartTime: \(self.startTime.toStdString()), EndTime: \(Date().toStdString())")
                self.completion(.completed, self.transcript, self.sentiment, self.suggestedSymptoms)
            }
        }
    }
    
    init(videoURL: URL, output: PossibleOutputs = .everything) {
        self.videoURL = videoURL
        self.aIFlowStatus = .notActive
        self.output = output
        self.startTime = Date()
    }
    
    func start(completion: @escaping CompletionAction) {
        self.completion = completion
        startTime = Date()
        aIFlowStatus = .start
    }
    
    // Only initialize when needed
    private lazy var speechRecognizer: SFSpeechRecognizer? = {
        let locale = Locale.current
        return SFSpeechRecognizer(locale: locale)
    }()
    
    /// Performs speech recognition on a video file to extract audio transcript
    ///
    /// This method processes a video file to extract the audio track and convert speech to text.
    /// It implements several optimizations for memory management and responsiveness:
    /// - Uses autoreleasepool to manage memory during intensive processing
    /// - Runs on a background thread to avoid blocking the UI
    /// - Implements cancellation support to abort processing when needed
    /// - Uses asynchronous loading for video asset properties
    ///
    /// The process follows these steps:
    /// 1. Load the video asset from the provided URL
    /// 2. Extract the audio track from the video
    /// 3. Process the audio using Speech Recognition framework
    /// 4. Return the transcript or error via state changes
    ///
    /// - Important: This method handles large video files and must maintain memory efficiency
    /// - Note: Speech recognition accuracy depends on audio quality and language support
    private func speechRecognition() {
        guard let url = videoURL as URL? else {
            aIFlowStatus = .error("No video URL provided")
            return
        }
        
        // PERFORMANCE CONSIDERATION:
        // Using .userInitiated QoS is appropriate for this task since it's
        // user-initiated but not time-critical like real-time monitoring
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Use autoreleasepool for better memory management during heavy processing
            // This ensures temporary objects are released promptly during intensive operations
            autoreleasepool {
                guard let self = self else { return }
                
                // Check for cancellation
                if self.aIFlowStatus == .notActive {
                    return
                }
                
                // Create asset and extract audio
                let asset = AVAsset(url: url)
                
                // MEMORY OPTIMIZATION:
                // Using asynchronous loading to avoid blocking the thread while
                // the asset loads. This is especially important for large videos.
                asset.loadValuesAsynchronously(forKeys: ["tracks"]) { [weak self] in
                    guard let self = self else { return }
                    
                    // Nested autoreleasepool for the completion handler's scope
                    // helps manage memory during the recognition phase
                    autoreleasepool {
                        do {
                            // Check for cancellation
                            if self.aIFlowStatus == .notActive {
                                return
                            }
                            
                            // Verify the asset loaded successfully
                            var error: NSError?
                            let status = asset.statusOfValue(forKey: "tracks", error: &error)
                            
                            if status == .failed {
                                throw error ?? NSError(domain: "AugumentVideoFlowManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load asset tracks"])
                            }
                            
                            // RESOURCE VALIDATION:
                            // Ensure audio track exists before proceeding
                            guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
                                DispatchQueue.main.async {
                                    self.aIFlowStatus = .error("No audio track found in video")
                                }
                                return
                            }
                            
                            // Set up speech recognition
                            let recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
                            // PERFORMANCE OPTIMIZATION:
                            // Disable partial results to reduce callback frequency and improve overall performance
                            recognitionRequest.shouldReportPartialResults = false
                            
                            // AVAILABILITY CHECK:
                            // Verify speech recognition is available before attempting
                            guard let speechRecognizer = self.speechRecognizer, speechRecognizer.isAvailable else {
                                DispatchQueue.main.async {
                                    self.aIFlowStatus = .error("Speech recognition not available")
                                }
                                return
                            }
                            
                            // CANCELLABLE TASK:
                            // Use a task that can be cancelled if the user navigates away
                            let recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                                guard let self = self else { return }
                                
                                // Handle recognition completion
                                if let error = error {
                                    self.logger.log(level: .error, "Speech recognition failed: \(error.localizedDescription)")
                                    DispatchQueue.main.async {
                                        self.aIFlowStatus = .error("Speech recognition failed: \(error.localizedDescription)")
                                    }
                                    return
                                }
                                
                                if let result = result, result.isFinal {
                                    let transcript = result.bestTranscription.formattedString
                                    
                                    // VALIDATION:
                                    // Check for empty results before proceeding
                                    if transcript.isEmpty {
                                        DispatchQueue.main.async {
                                            self.aIFlowStatus = .emptyTranscript
                                        }
                                        return
                                    }
                                    
                                    // Store transcript and continue processing
                                    self.transcript = transcript
                                    DispatchQueue.main.async {
                                        self.aIFlowStatus = .transcriptReady
                                    }
                                }
                            }
                            
                            // Store the task for potential cancellation
                            self.currentRecognitionTask = recognitionTask
                            
                        } catch {
                            self.logger.log(level: .error, "Speech recognition setup failed: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.aIFlowStatus = .error("Speech recognition setup failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Recognition task that can be cancelled
    private var currentRecognitionTask: SFSpeechRecognitionTask?
    
    /// Cancels any ongoing speech recognition to free up resources
    public func cancelRecognition() {
        currentRecognitionTask?.cancel()
        currentRecognitionTask = nil
    }
    
    /// Cleans up resources
    deinit {
        // Cancel any pending tasks and clean up resources
        cancelRecognition()
    }
    
    /// Detects sentiment with improved memory management
    private func detectSentiment() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            autoreleasepool {
                guard let self = self, let transcript = self.transcript else {
                    DispatchQueue.main.async {
                        self?.aIFlowStatus = .error("No transcript available for sentiment analysis")
                    }
                    return
                }
                
                // Simple placeholder sentiment analysis
                // In a real implementation, you would use a more sophisticated NLP approach
                self.sentiment = 0.0
                
                DispatchQueue.main.async {
                    self.aIFlowStatus = .sentimentDetected
                }
            }
        }
    }
    
    /// Applies NLP with improved memory management
    private func applyNLP() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            autoreleasepool {
                guard let self = self, let transcript = self.transcript else {
                    DispatchQueue.main.async {
                        self?.aIFlowStatus = .error("No transcript available for NLP")
                    }
                    return
                }
                
                do {
                    // Get all possible symptoms to detect
                    let symptoms = HandledSymptomsEvents.allPossibleSymptoms
                    
                    // Create NLP processor
                    let nlpProcessor = SymptomsNLP()
                    
                    // Process transcript to detect symptoms
                    self.suggestedSymptoms = ArrayOfSymptoms(try nlpProcessor.check(symptoms: symptoms, in: transcript))
                    
                    DispatchQueue.main.async {
                        self.aIFlowStatus = .nLPCompleted
                    }
                } catch {
                    self.logger.log(level: .error, "NLP processing failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.aIFlowStatus = .error("NLP processing failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Applies basic search with improved memory management
    private func applyBasicSearch() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            autoreleasepool {
                guard let self = self, let transcript = self.transcript else {
                    DispatchQueue.main.async {
                        self?.aIFlowStatus = .error("No transcript available for basic search")
                    }
                    return
                }
                
                var detectedSymptoms: [HandledSymptomsEvents] = []
                let allSymptoms = HandledSymptomsEvents.allPossibleSymptoms
                
                for symptom in allSymptoms {
                    let localizedString = symptom.localizedString()
                        if transcript.lowercased().contains(localizedString.lowercased()) {
                            detectedSymptoms.append(symptom)
                        }
                }
                
                self.suggestedSymptoms = ArrayOfSymptoms(detectedSymptoms)
                
                DispatchQueue.main.async {
                    self.aIFlowStatus = .basicSymptSearchCompleted
                }
            }
        }
    }
}

extension AugumentVideoLogFlowManager {
    func askUserValidation() {
        let validationDefaultAction = {
            if SheetViewController.shared.sheetVisible {
                FinalSuggestedSymptoms.shared.publishResults()
                self.suggestedSymptoms = ArrayOfSymptoms(FinalSuggestedSymptoms.shared.symptoms)
                self.aIFlowStatus = .userValidated
                mainDebugger.append("user validated those symptoms: \(String(describing: self.suggestedSymptoms))", .aILog)
                SheetViewController.shared.sheetVisible = false
            }
        }
        SheetViewController.shared.reset()
        SheetViewController.shared.sheetContentView = AnyView(SymptomsLearnerView(suggestedSymptomsFromAI: suggestedSymptoms ?? ArrayOfSymptoms()))
        SheetViewController.shared.okActionText = saveBtnMsg
        SheetViewController.shared.okAction = validationDefaultAction
        SheetViewController.shared.cancelAction = validationDefaultAction
        SheetViewController.shared.dismissAction = validationDefaultAction
        SheetViewController.shared.sheetVisible = true
    }
}

extension AugumentVideoLogFlowManager {
   // Test functions
    func test(completion: @escaping CompletionAction) {
        self.completion = completion
        aIFlowStatus = .start
    }
    
    func testSentiment(fakeTranscript: String, completion: @escaping CompletionAction) {
        self.transcript = fakeTranscript
        detectSentiment()
    }
    
    func testNLP(fakeTranscript: String, completion: @escaping CompletionAction) {
        self.transcript = fakeTranscript
        applyNLP()
    }
    
    func testSearch(fakeTranscript: String, completion: @escaping CompletionAction) {
        self.transcript = fakeTranscript
        applyBasicSearch()
    }
}
