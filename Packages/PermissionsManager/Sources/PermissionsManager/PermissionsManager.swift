//
//  Permissions Manager
//
//
//  Created by Roberto D'Angelo on 01/01/23.
//

import SwiftUI
import Combine
import OSLog

/// A manager class that handles permission requests and status tracking for various system permissions.
///
/// This class provides a centralized way to manage and track permission states for different system features
/// such as camera, microphone, notifications, etc. It supports both mandatory and optional permissions,
/// and provides real-time status updates through Combine publishers.
///
/// Example usage:
/// ```swift
/// let manager = PermissionsManager.shared
/// manager.personalize(
///     appName: "MyApp",
///     supportEmail: "support@myapp.com",
///     permissionsToHandle: [.camera, .microphone, .notifications]
/// )
/// ```
public class PermissionsManager: ObservableObject, Equatable, PermissionManagerEventsSubscriber {
    /// Compares two PermissionsManager instances for equality based on their unique identifiers.
    public static func == (lhs: PermissionsManager, rhs: PermissionsManager) -> Bool {
        lhs.id == rhs.id
    }

    /// A cancellable subscription for permission manager events
    public var permissionManagerEventSubscriber: AnyCancellable = AnyCancellable {}
    
    /// A publisher that emits permission manager protocol events
    public static let permissionManagerEventPublisher = PassthroughSubject<any PermissionManagerProtocol, Never>()
    
    /// The shared singleton instance of the PermissionsManager
    public static let shared: PermissionsManager = PermissionsManager()
    
    /// Logger instance for tracking permission-related events
    let logger = Logger(subsystem: "PermissionsManager", category: "Events")

    /// Unique identifier for this PermissionsManager instance
    internal let id: UUID = UUID()
    
    /// The name of the application requesting permissions
    internal var appName: String
    
    /// Support email address for permission-related inquiries
    internal var supportEmail: String
    
    /// Indicates if the manager is in standby mode
    public var standBy: Bool
    
    /// List of permissions that have been granted by the user
    @Published internal var grantedPermissions: [any PermissionManagerProtocol] = []
    
    /// List of permissions that have been denied by the user
    @Published internal var deniedPermissions: [any PermissionManagerProtocol] = []
    
    /// List of permissions that haven't been checked yet
    @Published internal var notCheckedYetPermissions: [any PermissionManagerProtocol] = []
    
    /// Indicates if all permissions have been granted
    @Published internal var allGranted: Bool = false
    
    /// Indicates if all mandatory permissions have been granted
    @Published internal var allMandatoryGranted: Bool = false
    
    /// Current status of all tracked permissions
    @Published internal var permissionsStatus: [PermissionStatus] = []
    
    /// Indicates if the permission check process has been skipped
    @Published internal var skipped: Bool = false {
        didSet {
            refresh()
        }
    }
    
    /// Indicates if the app can proceed with its main functionality
    @Published public var canGoAhead: Bool
    
    /// Dispatch group for coordinating permission checks
    internal let group = DispatchGroup()
    
    /// Internal storage for all permission types being managed
    private var permissionsInternal: [any PermissionManagerProtocol] = []
    
    /// Personalizes the PermissionsManager with app-specific settings and permission requirements.
    ///
    /// - Parameters:
    ///   - appName: The name of the application requesting permissions
    ///   - supportEmail: Email address for support inquiries
    ///   - permissionsToHandle: Array of permission types to manage
    public func personalize(appName: String,
                          supportEmail: String,
                          permissionsToHandle: [PermissionType]) {
        Task {
            self.appName = appName
            self.supportEmail = supportEmail
            permissionsManagerAppName = appName
            permissionsInternal = permissionsToHandle.map { $0.permission }
            for cnt in 0...(permissionsInternal.count - 1) {
                permissionsInternal[cnt].identifier.appName = appName
            }
            self.standBy = false
            await publishUpdatesInternal()
        }
    }

    /// Initializes a new PermissionsManager instance in standby mode.
    ///
    /// This initializer sets up the manager with default values and prepares it for personalization.
    /// The manager starts in standby mode and will not be ready for use until personalized.
    private init() {
        self.appName = defaultAppName4PermissionsManager
        self.supportEmail = defaultSupportEmail
        permissionsManagerAppName = self.appName
        self.permissionsInternal = []
        self.standBy = true
        self.canGoAhead = !self.standBy
        permissionManagerEventSubscriber = PermissionsManager.permissionManagerEventPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] permission in
                self?.handlePermissionManagerEvent(permission)
            })
    }

    /// Converts a PermissionType to its corresponding PermissionStatus.
    ///
    /// - Parameter permissionType: The permission type to look up
    /// - Returns: The corresponding PermissionStatus if found, nil otherwise
    public func permissionType2PermissionStatus(_ permissionType: PermissionType) -> PermissionStatus? {
        return permissionsStatus.first { status in
            status.permission.isEqualTo(permissionType.permission)
        }
    }
}

// MARK: - Private Functions
extension PermissionsManager {
    /// Handles permission manager events by refreshing the permission status.
    ///
    /// - Parameter permission: The permission that triggered the event
    public func handlePermissionManagerEvent(_ permission: any PermissionManagerProtocol) {
        Task {
            await publishUpdatesInternal()
        }
    }
    
    /// Returns the current list of permissions being managed.
    internal var permissions: [any PermissionManagerProtocol] {
        return Array(permissionsInternal)
    }
    
    /// Refreshes the current state of all permissions.
    internal func refresh() {
        Task {
            await publishUpdatesInternal()
        }
    }
    
    /// Updates the internal state of all permissions asynchronously.
    ///
    /// This method checks the authorization status of all permissions and updates
    /// the published properties accordingly. It uses a dispatch group to coordinate
    /// the asynchronous checks and ensures all updates happen on the main thread.
    private func publishUpdatesInternal() async {
        var grantedInternal: [any PermissionManagerProtocol] = []
        var deniedInternal: [any PermissionManagerProtocol] = []
        var notCheckedInternal: [any PermissionManagerProtocol] = []
        var statusInternal: [PermissionStatus] = []
        
        for permission in permissionsInternal.sorted(by: { lhs, rhs in
            lhs.identifier.name < rhs.identifier.name
        }) {
            group.enter()
            do {
                let status = await permission.returnAuthorizationStatus()
                statusInternal.append(PermissionStatus(permission: permission, status: status, id: UUID()))
                
                if status == .authorized, !grantedInternal.contains(where: { check in
                    check.identifier.name == permission.identifier.name
                }) {
                    grantedInternal.append(permission)
                }
                if status == .notDetermined, !notCheckedInternal.contains(where: { check in
                    check.identifier.name == permission.identifier.name
                }) {
                    notCheckedInternal.append(permission)
                }
                if status == .denied, !deniedInternal.contains(where: { check in
                    check.identifier.name == permission.identifier.name
                }) {
                    deniedInternal.append(permission)
                }
            }
            group.leave()
        }
        
        // Notify the main thread when all tasks are completed
        group.notify(queue: .main) {
            self.permissionsStatus = statusInternal
            self.grantedPermissions = grantedInternal
            self.deniedPermissions = deniedInternal
            self.notCheckedYetPermissions = notCheckedInternal
            
            // Update allGranted status
            if grantedInternal.count == self.permissionsInternal.count {
                self.allGranted = true
            } else {
                self.allGranted = false
            }
            
            // Check mandatory permissions
            let mandatoryPermissions: [any PermissionManagerProtocol] = self.permissionsInternal.filter { permission in
                permission.identifier.isMandatory == true
            }
            var mandatoryCheck: Bool = true
            for mandatoryPermission in mandatoryPermissions {
                if mandatoryPermission.authStatus != .authorized {
                    mandatoryCheck = false
                    break
                }
            }
            self.allMandatoryGranted = mandatoryCheck
            self.canGoAhead = (mandatoryCheck == true && self.skipped) || self.allGranted
        }
    }
    
    /// Returns an array of all denied permissions.
    ///
    /// - Returns: Array of permissions that have been denied by the user
    private func deniedPermissionsStatic() -> [any PermissionManagerProtocol] {
        var deniedPermissions: [any PermissionManagerProtocol] = []
        permissionsInternal.forEach { permission in
            permission.checkAuthorization { status in
                if status.isNotAuthorized, status.itHasBeenChecked {
                    deniedPermissions.append(permission)
                }
            }
        }
        return Array(deniedPermissions)
    }
    
    /// Returns an array of all granted permissions.
    ///
    /// - Returns: Array of permissions that have been granted by the user
    private func grantedPermissionsStatic() -> [any PermissionManagerProtocol] {
        var grantedPermissions: [any PermissionManagerProtocol] = []
        permissionsInternal.forEach { permission in
            permission.checkAuthorization { status in
                if status.isAuthorized {
                    grantedPermissions.append(permission)
                }
            }
        }
        return Array(grantedPermissions)
    }
    
    /// Returns an array of all permissions that haven't been checked yet.
    ///
    /// - Returns: Array of permissions that haven't been checked for authorization
    private func notCheckedYetdPermissionsStatic() -> [any PermissionManagerProtocol] {
        var notCheckedYetPermissions: [any PermissionManagerProtocol] = []
        permissionsInternal.forEach { permission in
            permission.checkAuthorization { status in
                if status.isNotCheckeYet {
                    notCheckedYetPermissions.append(permission)
                }
            }
        }
        return Array(notCheckedYetPermissions)
    }
    
    private func addPermission(permission: any PermissionManagerProtocol) {
        permissionsInternal.append(permission)
    }
    
#if os(iOS)
    static public let allPossiblePermissions: [any PermissionManagerProtocol] = [
        NotificationPermissionManager(isMandatory: true),
        
        // TODO: Verify if CriticalNotificationPermissionManager should be mandatory. See TODO.md for open questions.
        CriticalNotificationPermissionManager(isMandatory: true),
        SpeechPermissionManager(isMandatory: false),
        MicrophonePermissionManager(isMandatory: false),
        CameraPermissionManager(isMandatory: false),
        HealthPermissionManager(isMandatory: true),
        LocationPermissionManager(isMandatory: false)
    ]
#endif
#if os(watchOS)
    static public let allPossiblePermissions: [any PermissionManagerProtocol] = [
        NotificationPermissionManager(isMandatory: true),
        CriticalNotificationPermissionManager(isMandatory: true),
        HealthPermissionManager(isMandatory: true),
        LocationPermissionManager(isMandatory: false)
    ]
#endif
}

extension PermissionsManager {
#if os(iOS)
    public enum PermissionType: Equatable {
        case notifications(isMandatory: Bool)
        case criticalNotification(isMandatory: Bool)
        case speech(isMandatory: Bool)
        case microphone(isMandatory: Bool)
        case camera(isMandatory: Bool)
        case health(isMandatory: Bool)
        case location(isMandatory: Bool)
        
        public var permission: any PermissionManagerProtocol {
            switch self {
            case .speech(isMandatory: let isMandatory):
                return SpeechPermissionManager(isMandatory: isMandatory)
            case .microphone(isMandatory: let isMandatory):
                return MicrophonePermissionManager(isMandatory: isMandatory)
            case .camera(isMandatory: let isMandatory):
                return CameraPermissionManager(isMandatory: isMandatory)
            case .notifications(isMandatory: let isMandatory):
                return NotificationPermissionManager(isMandatory: isMandatory)
            case .criticalNotification(isMandatory: let isMandatory):
                return CriticalNotificationPermissionManager(isMandatory: isMandatory)
            case .health(isMandatory: let isMandatory):
                return HealthPermissionManager(isMandatory: isMandatory)
            case .location(isMandatory: let isMandatory):
                return LocationPermissionManager(isMandatory: isMandatory)
            }
        }
    }
#endif
    
#if os(watchOS)
    public enum PermissionType: Equatable {
        case notifications(isMandatory: Bool)
        case criticalNotification(isMandatory: Bool)
        case health(isMandatory: Bool)
        case location(isMandatory: Bool)
        
        public var permission: any PermissionManagerProtocol {
            switch self {
            case .notifications(isMandatory: let isMandatory):
                return NotificationPermissionManager(isMandatory: isMandatory)
            case .criticalNotification(isMandatory: let isMandatory):
                return CriticalNotificationPermissionManager(isMandatory: isMandatory)
            case .health(isMandatory: let isMandatory):
                return HealthPermissionManager(isMandatory: isMandatory)
            case .location(isMandatory: let isMandatory):
                return LocationPermissionManager(isMandatory: isMandatory)
            }
        }
    }
#endif
}
