//
//  Supporting Structs.swift
//  
//
//  Created by Roberto D'Angelo on 04/01/23.
//

/// Supporting data structures for the PermissionsManager framework.
///
/// These structures provide standardized ways to represent permission status,
/// UI elements, messages, and identifiers throughout the framework.

import Foundation

/// Represents the current status of a specific permission.
///
/// This structure combines a permission manager with its current authorization status,
/// making it easy to track and display permission states in the UI.
///
/// Example Usage:
/// ```swift
/// let status = PermissionStatus(
///     permission: cameraManager,
///     status: .authorized,
///     id: UUID()
/// )
/// ```
public struct PermissionStatus: Identifiable {
    /// The permission manager being tracked
    public var permission: any PermissionManagerProtocol
    
    /// Current authorization status for the permission
    public var status: AuthorizationStatus
    
    /// Unique identifier for this status instance
    public var id: UUID = UUID()
}

/// Collection of icons used to represent different permission states.
///
/// This structure provides consistent icon names for different permission states,
/// ensuring a uniform appearance throughout the UI.
///
/// Example Usage:
/// ```swift
/// let icons = PermissionIcons(
///     mainIcon: "camera.circle",
///     deniedIcon: "camera.circle.slash"
/// )
/// ```
public struct PermissionIcons: Equatable {
    /// Icon for the main permission state
    var mainIcon: String = "checkmark.circle"
    
    /// Icon for when permission is denied
    var deniedIcon: String = "xmark.circle"
    
    /// Icon for when permission status is undetermined
    var undeterminedIcon: String = "questionmark.circle"
    
    /// Icon for when there's an error with the permission
    var errorIcon: String = "exclamationmark.circle"
}

/// Collection of localized messages for permission-related UI elements.
///
/// This structure provides consistent messaging throughout the permission
/// request and management process.
///
/// Example Usage:
/// ```swift
/// let messages = PermissionMessages(
///     description: "Camera access is needed to take photos",
///     okMessage: "Camera access granted",
///     noOkMessage: "Camera access denied",
///     recoveryMsg: "Please enable camera access in Settings"
/// )
/// ```
public struct PermissionMessages: Equatable {
    /// Description of why the permission is needed
    var description: String
    
    /// Message shown when permission is granted
    var okMessage: String
    
    /// Message shown when permission is denied
    var noOkMessage: String
    
    /// Instructions for recovering from a denied state
    var recoveryMsg: String
}

/// Unique identifier and metadata for a permission.
///
/// This structure provides a way to uniquely identify and describe
/// different types of permissions in the system.
///
/// Example Usage:
/// ```swift
/// let identifier = PermissionIdentifier(
///     name: "Camera",
///     debugName: "CameraPermission",
///     appName: "MyApp",
///     isMandatory: true
/// )
/// ```
public struct PermissionIdentifier: Equatable {
    /// User-facing name of the permission
    var name: String
    
    /// Developer-facing name for debugging
    var debugName: String
    
    /// Name of the app requesting the permission
    var appName: String
    
    /// Whether this permission is required for app functionality
    var isMandatory: Bool
    
    /// Unique identifier for this permission
    var id: UUID = UUID()
}
