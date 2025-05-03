//
//  WatchMainClasses.swift
//  MirrorHR WatchKit Extension
//
//  Created by Roberto D'Angelo on 23/10/2020.
//

import HealthKit
import SharedPkg
import SwiftUI
import WatchConnectivity
import PermissionsManager

/// A class that manages workout sessions and heart rate monitoring on Apple Watch
/// - Handles workout session management
/// - Implements HKWorkoutSessionDelegate for HealthKit integration
/// - Manages real-time heart rate monitoring
/// - Provides workout session state management
class MirrorHRWorkOut: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    static let shared = MirrorHRWorkOut()
    
    enum WorkOutState: Equatable {
        case stopped(source: DeviceModels)
        case running(source: DeviceModels)
        case delayedStop(forHowLong: TimeInterval)
        case error(description: String)
    }
    
    @Published public var parentalControl: Bool = false
    @Published public var bpmFromWatch: BPMFromWatch
    @Published public var healthAuthorizationStatus: AuthorizationStatus = .notDetermined
    
    @Published var workOutState: WorkOutState {
        didSet {
            if oldValue != workOutState {
                switch workOutState {
                case let .stopped(source: source):
                    stopWorkoutAfterXTime(forHowLong: 30)
                    endDate = Date()
                    if source == .appleWatch {
                        CommunicationManagerWatch.shared.stopFromWatch()
                    }
                case let .running(source: source):
                    startWorkout()
                    if source == .appleWatch {
                        CommunicationManagerWatch.shared.startFromWatch()
                    }
                    startDate = Date()
                    endDate = startDate
                case let .error(description: description):
                    // IMPORTANT! Implement this properly
                    let sessionMessage = SessionMessage(command: .error(source: .appleWatch, destination: .iPhone, errorMessage: description))
                    CommunicationManagerWatch.shared.sendMessage(message: sessionMessage.messageDictionary())
                    mainDebugger.append("Error on workout: \(description)", .error)
                case let .delayedStop(forHowLong: forHowLong):
                    stopWorkoutAfterXTime(forHowLong: forHowLong)
                }
            }
        }
    }
    
    private lazy var communicationManager: CommunicationManagerWatch = .shared
    private(set) var startDate = Date(timeIntervalSince1970: 0)
    private(set) var endDate = Date(timeIntervalSince1970: 0)
    var length: TimeInterval {
        endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
    }
    
    typealias HKQueryUpdateHandler = ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Swift.Void)
    
    private let heartRateQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var heartRateQuery: HKQuery?
    private let workoutConfiguration = HKWorkoutConfiguration()
    
    func checkPermissions() {
        // Impt:  checking that we have permissions to read/write data every time we start a session :-)
        HealthAuthorizationManager().requestAuthorizationToReadHeartRateData { status in
            DispatchQueue.main.async {
                self.healthAuthorizationStatus = status
                switch status {
                case .authorized:
                    mainDebugger.append("ok we can read/write health data")
                case .notAvailable, .custom, .error, .unknown:
                    mainDebugger.append("Health Data error: \(self.description)", .error, sourceModule: "MirrorHRWorkOut checkPermissions")
                    return
                case .denied:
                    mainDebugger.append("User has not granted permissions to read health data", .error, sourceModule: "MirrorHRWorkOut checkPermissions")
                case .notDetermined:
                    break
                }
            }
        }
    }
    
    private func startWorkout() {
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            workoutSession?.delegate = self
        } catch {
            workOutState = .error(description: "workout session error in configuration. Try again or reboot the watch")
        }
        workoutSession?.startActivity(with: nil)
        mainDebugger.append("workout session started", .greenFlag)
        bpmFromWatch.boot()
    }
    
    private func stopWorkoutAfterXTime(forHowLong: TimeInterval) {
        bpmFromWatch.stop()
        // keep the workout session active for another 15 minutes so that if the user wants to restart/restop it can be done from the phone, while after 15 min stop it so it will save battery
        Timer.scheduledTimer(withTimeInterval: forHowLong, repeats: false) { [self] _ in
            if case .delayedStop = workOutState {
                workoutSession?.end()
            }
        }
    }
    
    public override init() {
        workOutState = .stopped(source: .appleWatch)
        bpmFromWatch = BPMFromWatch()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        // initial handshaking
        super.init()
    }
    
    // MARK: QUERY WORKOUT TO GET HEART RATE
    func getQuery(date: Date, quantityType: HKQuantityType) -> HKQuery {
        let datePredicate = HKQuery.predicateForSamples(withStart: date, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
        
        let updateHandler: HKQueryUpdateHandler = { [self] _, samples, _, _, _ in
            if let quantitySamples = samples as? [HKQuantitySample] {
                quantitySamples.forEach { sample in
                    // MARK: 1. check if it's heart rate
                    guard sample.quantityType == heartRateQuantityType else {
                        return
                    }
                    
                    // MARK: 2. create a fresh BpmFromWatch
                    let freshBpmFromWatch: BPMFromWatch = .init(
                        bpm: Int(60.0 * sample.quantity.doubleValue(for: HKUnit(from: "count/s"))),
                        startDate: sample.startDate,
                        endDate: sample.endDate
                    )
                    
                    // MARK: 3. check conditions that is's all ok, including avoid duplicated values
                    guard freshBpmFromWatch.bpm != 0, case .running = workOutState, self.bpmFromWatch != freshBpmFromWatch else {
                        return
                    }
                    
                    // MARK: 4. sending the BPM from watch to phone here
                    let sessionMessage = SessionMessage(bpmFromWatch: freshBpmFromWatch)
                    communicationManager.sendMessage(message: sessionMessage.messageDictionary())
                    
                    // MARK: 5.updating BPM for views
                    DispatchQueue.main.async {
                        self.bpmFromWatch = freshBpmFromWatch
                    }
                }
            }
        }
        
        let query = HKAnchoredObjectQuery(
            type: quantityType,
            predicate: queryPredicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: updateHandler
        )
        
        query.updateHandler = updateHandler
        return query
    }
    
    public func workoutSession(_: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from _: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            break
        }
    }
    
    public func workoutSession(_: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.workOutState = .error(description: error.localizedDescription)
        }
    }
    
    func workoutDidStart(_ date: Date) {
        let query = getQuery(date: date, quantityType: heartRateQuantityType)
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    func workoutDidEnd(_: Date) {
        if let myQuery = heartRateQuery {
            healthStore.stop(myQuery)
        }
        workoutSession = nil
    }
}
