//
//  Microphone Permissions Manager.swift
//  
//
//  Created by Roberto D'Angelo on 02/01/23.
//

#if os(iOS)
import Foundation
import Combine

import AVFoundation

/// A permission manager that handles microphone access permissions using AVFoundation.
///
/// This class manages the authorization state for microphone access, including:
/// - Checking current authorization status
/// - Requesting microphone access
/// - Handling authorization changes
///
/// Important Setup Requirements:
/// - Add "Privacy - Microphone Usage Description" to Info.plist
/// - Configure appropriate privacy descriptions
///
/// Thread Safety:
/// - All state mutations are performed on the main thread
/// - Authorization status changes trigger events through Combine
///
/// Example Usage:
/// ```swift
/// let microphoneManager = MicrophonePermissionManager(isMandatory: true)
/// microphoneManager.checkAuthorization { status in
///     // Handle authorization status
/// }
/// ```
public class MicrophonePermissionManager: PermissionManagerProtocol {
    
    // MARK: - Properties
    
    /// Unique identifier for the microphone permission
    public var identifier: PermissionIdentifier
    
    /// Icons used to represent the permission state in the UI
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "mic.circle", deniedIcon: "mic.slash.circle")
    
    /// Localized messages for permission-related UI
    public var messages: PermissionMessages
    
    /// Publisher for permission-related events
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    /// Current authorization status for microphone access
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    /// Initializes a new microphone permission manager.
    ///
    /// - Parameter isMandatory: Whether this permission is required for app functionality
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(
            name: "MicrophoneLocalized".localized(),
            debugName: "Microphone",
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
    
    /// Checks the current authorization status for microphone access.
    ///
    /// - Parameter completion: Callback with the current authorization status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            authStatus = .authorized
        case .notDetermined:
            authStatus = .notDetermined
        case .restricted:
            authStatus = .custom(customAuth: "Restricted")
        case .denied:
            authStatus = .denied
        @unknown default:
            authStatus = .unknown
        }
        completion(authStatus)
    }
    
    /// Returns the current authorization status asynchronously.
    ///
    /// - Returns: The current authorization status
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        do {
            switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized:
                authStatus = .authorized
            case .notDetermined:
                authStatus = .notDetermined
            case .restricted:
                authStatus = .custom(customAuth: "Restricted")
            case .denied:
                authStatus = .denied
            @unknown default:
                authStatus = .unknown
            }
            return authStatus
        }
    }
    
    /// Requests authorization for microphone access.
    ///
    /// - Parameter completion: Callback with the result of the authorization request
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { [self] granted in
            if granted {
                authStatus = .authorized
            } else {
                authStatus = .denied
            }
            completion(authStatus)
        }
    }
    
    // MARK: - Equatable Conformance
    
    /// Compares two microphone permission managers for equality.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand side microphone permission manager
    ///   - rhs: Right-hand side microphone permission manager
    /// - Returns: True if the managers are equal, false otherwise
    public static func == (lhs: MicrophonePermissionManager, rhs: MicrophonePermissionManager) -> Bool {
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
#endif
