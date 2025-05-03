//
//  PermissionsManager Enums.swift
//  
//
//  Created by Roberto D'Angelo on 21/12/22.
//

/// Enumerations supporting the PermissionsManager framework.
///
/// These enums define the types of permissions that can be managed,
/// their possible states, and related error conditions.

import Foundation
import SwiftUI

/// Types of system permissions that can be managed by the framework.
///
/// This enum defines all the permission types that the PermissionsManager
/// can handle. Each case represents a different system permission that
/// may need to be requested from the user.
public enum PermissionType: CaseIterable {
    /// Standard notification permissions
    case notification
    
    /// Critical alert notification permissions
    case criticalAlert
    
    /// HealthKit data access permissions
    case health
    
    /// Speech recognition permissions
    case speech
    
    /// Microphone access permissions
    case microphone
    
    /// Camera access permissions
    case camera
    
    /// Photo library access permissions
    case photoLibrary
}

/// Represents the current state of a permission authorization request.
///
/// This enum provides a comprehensive set of states that a permission
/// can be in, along with associated UI elements like colors and icons
/// for consistent presentation.
public enum AuthorizationStatus: Equatable {
    /// Permission has not been requested yet
    case notDetermined
    
    /// Permission has been explicitly denied by the user
    case denied
    
    /// Permission has been granted by the user
    case authorized
    
    /// Custom authorization state with additional context
    case custom(customAuth: String)
    
    /// Authorization state is unknown
    case unknown
    
    /// An error occurred during authorization
    case error(error: Error)
    
    /// The requested permission is not available on this device
    case notAvailable
    
    /// Human-readable description of the authorization status
    public var localizedDescription: String {
        switch self {
        case .notDetermined:
            return "NotDeterminedLocalized".localized()
        case .denied:
            return "DeniedLocalized".localized()
        case .authorized:
            return "AuthorizedLocalized".localized()
        case .unknown:
            return "UnknownLocalized".localized()
        case .custom(customAuth: let customAuth):
            return "\(customAuth)".localized()
        case .error(error: let error):
            return "\(error.localizedDescription)"
        case .notAvailable:
            return "NotAvailableLocalized".localized()
        }
    }
    
    /// Color associated with this authorization status for UI display
    public var color: Color {
        switch self {
        case .notDetermined:
            return .orange
        case .denied:
            return .red
        case .authorized:
            return .green
        case .unknown:
            return .yellow
        case .custom:
            return .purple
        case .error:
            return .red
        case .notAvailable:
            return .red
        }
    }
    
    /// System icon name associated with this authorization status
    public var icon: String {
        switch self {
        case .notDetermined:
            return "questionmark.circle.filled"
        case .denied:
            return "xmark.circle.fill"
        case .authorized:
            return "checkmark.circle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        case .custom:
            return "checkmark.circle.trianglebadge.exclamationmark"
        case .error:
            return "hand.raised.circle.fill"
        case .notAvailable:
            return "hand.raised.slash.fill"
        }
    }
    
    /// Technical description of the authorization status for debugging
    public var debugDescription: String {
        switch self {
        case .notDetermined:
            return "NotDetermined"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .unknown:
            return "Unknown"
        case .custom(customAuth: let customAuth):
            return "\(customAuth)"
        case .error(error: let error):
            return "\(error)"
        case .notAvailable:
            return "NotAvailable"
        }
    }
    
    /// Whether this status represents an authorized state
    public var isAuthorized: Bool {
        switch self {
        case .notDetermined, .denied, .custom, .unknown, .error, .notAvailable:
            return false
        case .authorized:
            return true
        }
    }
    
    /// Whether this status represents an unauthorized state
    public var isNotAuthorized: Bool {
        switch self {
        case .notDetermined, .denied, .custom, .unknown, .error, .notAvailable:
            return true
        case .authorized:
            return false
        }
    }
    
    /// Whether this permission has not been checked yet
    public var isNotCheckeYet: Bool {
        switch self {
        case .notDetermined:
            return true
        case .authorized, .denied, .custom, .unknown, .error, .notAvailable:
            return false
        }
    }
    
    /// Whether this permission has been checked at least once
    public var itHasBeenChecked: Bool {
        switch self {
        case .notDetermined:
            return false
        case .authorized, .denied, .custom, .unknown, .error, .notAvailable:
            return true
        }
    }
    
    /// Internal value for equality comparison
    private var value: String? {
        return String(describing: self).components(separatedBy: "(").first
    }
    
    /// Equality comparison operator
    public static func == (lhs: AuthorizationStatus, rhs: AuthorizationStatus) -> Bool {
        lhs.value == rhs.value
    }
}

/// Errors that can occur during permission management.
///
/// This enum defines the various error conditions that might arise
/// while managing permissions, along with appropriate error messages
/// and error objects.
enum PermissionsErrors {
    /// The requested permission type does not exist
    case permissionTypeNotExist
    
    /// Human-readable description of the error
    public var description: String {
        switch self {
        case .permissionTypeNotExist:
            return "PermissionsManagerErrorTypeDoesNotExistLocalized"
        }
    }
    
    /// NSError representation of the error
    public var error: Error {
        switch self {
        case .permissionTypeNotExist:
            return NSError(
                domain: "Permissions Manager",
                code: 101,
                userInfo: [NSLocalizedDescriptionKey: self.description.debugDescription]
            )
        }
    }
}
