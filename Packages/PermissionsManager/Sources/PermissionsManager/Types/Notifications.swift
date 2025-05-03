//
//  UserNotifications Permissions Handling
//  
//
//  Created by Roberto D'Angelo on 01/01/23.
//

import Foundation
import UserNotifications
import Combine
import OSLog

/// A permission manager that handles user notification permissions using UserNotifications framework.
///
/// This class manages the authorization state for push notifications and local notifications,
/// including checking current status, requesting permissions, and handling authorization changes.
///
/// Important Setup Requirements:
/// - Add appropriate privacy descriptions to Info.plist
/// - Configure notification capabilities in project settings
/// - Set up notification categories and actions if needed
///
/// Thread Safety:
/// - All state mutations are performed on the main thread
/// - Notification center callbacks are handled safely
///
/// Example Usage:
/// ```swift
/// let notificationManager = NotificationPermissionManager(isMandatory: true)
/// notificationManager.checkAuthorization { status in
///     // Handle authorization status
/// }
/// ```
public class NotificationPermissionManager: PermissionManagerProtocol {
    
    // MARK: - Properties
    
    /// Unique identifier for the notifications permission
    public var identifier: PermissionIdentifier
    
    /// Icons used to represent the permission state in the UI
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "bell.circle", deniedIcon: "bell.slash.circle")
    
    /// Localized messages for permission-related UI
    public var messages: PermissionMessages
    
    /// The notification center instance for managing notification permissions
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    /// The notification options to request from the user
    private var notificationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
    
    /// Logger instance for tracking notification-related events
    let logger = Logger(subsystem: "PermissionManager", category: "Notification")
    
    /// Publisher for permission-related events
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    /// Current authorization status for notifications
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    /// Initializes a new notification permission manager.
    ///
    /// - Parameter isMandatory: Whether this permission is required for app functionality
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(
            name: "NotificationsLocalized".localized(),
            debugName: "Notifications",
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
    
    /// Checks the current authorization status for notifications.
    ///
    /// - Parameter completion: Callback with the current authorization status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { [self] unNotificationSetting in
            switch unNotificationSetting.authorizationStatus {
            case .notDetermined:
                authStatus = .notDetermined
            case .denied:
                authStatus = .denied
            case .authorized:
                authStatus = .authorized
            case .provisional:
                authStatus = .custom(customAuth: "provisional")
            case .ephemeral:
                authStatus = .custom(customAuth: "ephemeral")
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
            switch unNotificationSetting.authorizationStatus {
            case .notDetermined:
                authStatus = .notDetermined
            case .denied:
                authStatus = .denied
            case .authorized:
                authStatus = .authorized
            case .provisional:
                authStatus = .custom(customAuth: "provisional")
            case .ephemeral:
                authStatus = .custom(customAuth: "ephemeral")
            @unknown default:
                authStatus = .unknown
            }
            return authStatus
        }
    }
    
    /// Requests authorization for notifications.
    ///
    /// - Parameter completion: Callback with the result of the authorization request
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        notificationCenter.requestAuthorization(options: notificationOptions) { [self] granted, error in
            if let error = error {
                logger.error("Error in Notification Permissions Manager - Request authorization: \(error.localizedDescription)")
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
    
    /// Compares two notification permission managers for equality.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand side notification permission manager
    ///   - rhs: Right-hand side notification permission manager
    /// - Returns: True if the managers are equal, false otherwise
    public static func == (lhs: NotificationPermissionManager, rhs: NotificationPermissionManager) -> Bool {
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
