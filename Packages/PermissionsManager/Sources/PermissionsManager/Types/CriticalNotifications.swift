//
//  Critical Notifications.swift
//  
//
//  Created by Roberto D'Angelo on 03/01/23.
//

import Foundation
import UserNotifications
import Combine
import OSLog

/// A permission manager that handles critical notification permissions using UserNotifications framework.
///
/// This class manages the authorization state for critical notifications, including:
/// - Checking current authorization status
/// - Requesting critical notification permissions
/// - Handling authorization changes
///
/// Important Setup Requirements:
/// - Add appropriate notification capabilities in your app's entitlements
/// - Configure notification settings in your app's Info.plist
///
/// Thread Safety:
/// - All state mutations are performed on the main thread
/// - Authorization status changes trigger events through Combine
///
/// Example Usage:
/// ```swift
/// let criticalNotificationManager = CriticalNotificationPermissionManager(isMandatory: true)
/// criticalNotificationManager.checkAuthorization { status in
///     // Handle authorization status
/// }
/// ```
public class CriticalNotificationPermissionManager: PermissionManagerProtocol {

    // MARK: - Properties
    
    /// Icons used to represent the permission state in the UI
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "bell.badge.circle", deniedIcon: "bell.slash.circle")
    
    /// Localized messages for permission-related UI
    public var messages: PermissionMessages
    
    /// Unique identifier for the critical notifications permission
    public var identifier: PermissionIdentifier
    
    /// The notification center instance for managing notification permissions
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    /// The authorization options for critical notifications
    private var notificationOptions: UNAuthorizationOptions = [.criticalAlert]
    
    /// Logger instance for tracking permission-related events
    let logger = Logger(subsystem: "PermissionManager", category: "CriticalNotification")
    
    /// Publisher for permission-related events
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    /// Current authorization status for critical notifications
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    /// Initializes a new critical notification permission manager.
    ///
    /// - Parameter isMandatory: Whether this permission is required for app functionality
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(
            name: "CriticalNotificationsLocalized".localized(),
            debugName: "Critical Notifications",
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
    
    // MARK: - Event Handling
    
    /// Dispatches a permission event to notify observers of status changes
    public func dispatchEvent() {
        eventPublisher.send(self)
    }
    
    // MARK: - Authorization Status
    
    /// Checks the current authorization status for critical notifications.
    ///
    /// - Parameter completion: Callback with the current authorization status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { [self] unNotificationSetting in
            switch unNotificationSetting.criticalAlertSetting {
            case .notSupported:
                authStatus = .notDetermined
            case .disabled:
                authStatus = .denied
            case .enabled:
                authStatus = .authorized
            @unknown default:
                authStatus = .unknown
            }
            completion(authStatus)
        }
    }
    
    /// Returns the current authorization status asynchronously.
    ///
    /// - Returns: The current authorization status
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        do {
            let unNotificationSetting = await notificationCenter.notificationSettings()
            switch unNotificationSetting.criticalAlertSetting {
            case .notSupported:
                authStatus = .notDetermined
            case .disabled:
                authStatus = .denied
            case .enabled:
                authStatus = .authorized
            @unknown default:
                authStatus = .unknown
            }
            return authStatus
        }
    }
    
    /// Requests authorization for critical notifications.
    ///
    /// - Parameter completion: Callback with the result of the authorization request
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        notificationCenter.requestAuthorization(options: notificationOptions) { [self] granted, error in
            if let error = error {
                logger.error("Error in Permissions Manager - Request Authorization: \(error.localizedDescription)")
                authStatus = .error(error: error)
            } else {
                if granted {
                    authStatus = .authorized
                } else {
                    authStatus = .denied
                }
            }
            completion(authStatus)
        }
    }
    
    // MARK: - Equatable Conformance
    
    /// Compares two critical notification permission managers for equality.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand side critical notification permission manager
    ///   - rhs: Right-hand side critical notification permission manager
    /// - Returns: True if the managers are equal, false otherwise
    public static func == (lhs: CriticalNotificationPermissionManager, rhs: CriticalNotificationPermissionManager) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    /// Compares this permission manager with another protocol-conforming type.
    ///
    /// - Parameter other: Another permission manager to compare with
    /// - Returns: True if the managers are equal, false otherwise
    public func isEqualTo(_ other: any PermissionManagerProtocol) -> Bool {
        return (self.identifier.debugName == other.identifier.debugName && self.identifier.appName == other.identifier.appName)
    }
}
