import Foundation
import Combine
import HealthKit
import OSLog

/// HealthPermissionManager handles health data permissions using HealthKit.
///
/// This class is marked as @unchecked Sendable because:
/// 1. All mutable state (_authStatus) is protected by a serial DispatchQueue
/// 2. HealthKit operations are thread-safe by design
/// 3. Publisher and UI updates are dispatched to the main thread
/// 4. Logger is thread-safe by design
///
/// Thread Safety Implementation:
/// - Uses serial DispatchQueue for _authStatus synchronization
/// - All state mutations are performed within queue.async blocks
/// - UI updates are always dispatched to the main thread
/// - Completion handlers are called on the main thread
///
/// Future Modernization Notes:
/// 1. Consider migrating to @MainActor when ready to update concurrency model
/// 2. Replace DispatchQueue with actor isolation
/// 3. Use async/await for HealthKit operations
/// 4. Consider splitting into smaller, focused types:
///    - HealthKitAuthorizationService
///    - HealthKitTypeProvider
///    - PermissionStateManager
///
/// Known Limitations:
/// - Manual thread synchronization might be more complex than necessary
/// - Completion handler pattern could be simplified with async/await
/// - State updates might benefit from Combine publishers
///
/// - Important: When modifying this class, ensure all state mutations
///             are performed within the serial queue to maintain thread safety.
public class HealthPermissionManager: PermissionManagerProtocol, Equatable, @unchecked Sendable {
    public func isEqualTo(_ other: any PermissionManagerProtocol) -> Bool {
        return self.identifier == other.identifier
    }
    
    // MARK: - Properties

    public var identifier: PermissionIdentifier
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "heart.circle", deniedIcon: "heart.slash.circle")
    public var messages: PermissionMessages

    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    private let logger = Logger(subsystem: "PermissionManager", category: "Health")

    // MARK: - Thread Safety
    
    /// Serial queue for thread-safe state mutations
    /// - Note: All access to _authStatus must be synchronized through this queue
    private let queue = DispatchQueue(label: "com.mirror-labs.Epilepsy-Research-Kit.PermissionManager.healthPermissionManager.queue")

    /// Internal authorization status with thread-safe access
    /// - Warning: Never access _authStatus directly; use queue.sync/async
    private var _authStatus: AuthorizationStatus = .notDetermined
    
    public var authStatus: AuthorizationStatus {
        get {
            return queue.sync { _authStatus }
        }
        set {
            queue.async {
                let oldValue = self._authStatus
                self._authStatus = newValue
                if oldValue != newValue {
                    DispatchQueue.main.async {
                        self.dispatchEvent()
                    }
                }
            }
        }
    }

    // HealthKit-specific properties
    private let healthStore = HKHealthStore()
    private let heartRateIdentifier: HKQuantityTypeIdentifier = .heartRate
    private let oxygenSaturationIdentifier: HKQuantityTypeIdentifier = .oxygenSaturation
    private let hrvIdentifier: HKQuantityTypeIdentifier = .heartRateVariabilitySDNN
    private let respiratoryRateIdentifier: HKQuantityTypeIdentifier = .respiratoryRate
    private let sleepIdentifier: HKCategoryTypeIdentifier = .sleepAnalysis
    private let workOutType: HKWorkoutType = HKObjectType.workoutType()

    // MARK: - Initialization

    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(
            name: "HealthDataLocalized".localized(),
            debugName: "Health Data",
            appName: permissionsManagerAppName,
            isMandatory: isMandatory
        )
        messages = PermissionMessages(
            description: defaultDescriptionMsg(permissionName: identifier.name),
            okMessage: defaultOkMsg(),
            noOkMessage: defaultNoOkMsg(permissionName: identifier.name),
            recoveryMsg: defaultRecoveryMsg(appName: identifier.appName)
        )
    }

    // MARK: - Methods

    public func dispatchEvent() {
        eventPublisher.send(self)
    }

    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        queue.async {
            let status = self.healthStoreAuthorizationStatus()
            self.authStatus = status
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }

    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        await withCheckedContinuation { continuation in
            queue.async {
                let status = self.healthStoreAuthorizationStatus()
                self.authStatus = status
                continuation.resume(returning: status)
            }
        }
    }

    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let heartRate = HKObjectType.quantityType(forIdentifier: heartRateIdentifier),
              let oxygenSaturation = HKObjectType.quantityType(forIdentifier: oxygenSaturationIdentifier),
              let hrv = HKObjectType.quantityType(forIdentifier: hrvIdentifier),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: respiratoryRateIdentifier),
              let sleep = HKObjectType.categoryType(forIdentifier: sleepIdentifier)
        else {
            queue.async {
                self.authStatus = .notAvailable
                DispatchQueue.main.async {
                    completion(self.authStatus)
                }
            }
            return
        }

        let typesToWrite: Set<HKSampleType> = [heartRate, oxygenSaturation, hrv, sleep, respiratoryRate, workOutType]
        let typesToRead: Set<HKObjectType> = [heartRate, oxygenSaturation, hrv, sleep, respiratoryRate, workOutType]

        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] userWasShownPermissionView, error in
            guard let self = self else { return }
            self.queue.async {
                if let error = error {
                    self.logger.error("Error in HealthPermissionManager: \(error.localizedDescription)")
                    self.authStatus = .error(error: error)
                    DispatchQueue.main.async {
                        completion(self.authStatus)
                    }
                    return
                }

                if userWasShownPermissionView {
                    self.authStatus = self.healthStoreAuthorizationStatus()
                } else {
                    self.authStatus = .denied
                }

                DispatchQueue.main.async {
                    completion(self.authStatus)
                }
            }
        }
    }

    // Private method to get HealthKit authorization status
    private func healthStoreAuthorizationStatus() -> AuthorizationStatus {
        guard HKHealthStore.isHealthDataAvailable(),
              let heartRate = HKObjectType.quantityType(forIdentifier: heartRateIdentifier),
              let oxygenSaturation = HKObjectType.quantityType(forIdentifier: oxygenSaturationIdentifier),
              let hrv = HKObjectType.quantityType(forIdentifier: hrvIdentifier),
              let respiratoryRate = HKObjectType.quantityType(forIdentifier: respiratoryRateIdentifier),
              let sleep = HKObjectType.categoryType(forIdentifier: sleepIdentifier)
        else {
            return .notAvailable
        }

        let heartRateStatus = healthStore.authorizationStatus(for: heartRate)
        let oxygenSaturationStatus = healthStore.authorizationStatus(for: oxygenSaturation)
        let hrvStatus = healthStore.authorizationStatus(for: hrv)
        let respiratoryRateStatus = healthStore.authorizationStatus(for: respiratoryRate)
        let sleepStatus = healthStore.authorizationStatus(for: sleep)

        if heartRateStatus == .sharingAuthorized,
           oxygenSaturationStatus == .sharingAuthorized,
           hrvStatus == .sharingAuthorized,
           respiratoryRateStatus == .sharingAuthorized,
           sleepStatus == .sharingAuthorized {
            return .authorized
        } else if heartRateStatus == .notDetermined,
                  oxygenSaturationStatus == .notDetermined,
                  hrvStatus == .notDetermined,
                  respiratoryRateStatus == .notDetermined,
                  sleepStatus == .notDetermined {
            return .notDetermined
        } else {
            return .denied
        }
    }

    // Conformance to Equatable
    public static func ==(lhs: HealthPermissionManager, rhs: HealthPermissionManager) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
