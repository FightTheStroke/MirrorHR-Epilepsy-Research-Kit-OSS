//
//  Permissions Manager Protocols
//  
//
//  Created by Roberto D'Angelo on 01/01/23.
//

/// Core protocols for the PermissionsManager framework.
///
/// These protocols define the required functionality for permission management,
/// including permission status tracking, authorization requests, and event handling.

import Foundation
import Combine

/// Protocol defining the core functionality required for managing a specific permission type.
///
/// This protocol provides a standardized interface for handling different types of system permissions
/// (e.g., camera, microphone, notifications). It includes properties for UI elements, status tracking,
/// and methods for requesting and checking authorization status.
///
/// Example Implementation:
/// ```swift
/// class MyPermissionManager: PermissionManagerProtocol {
///     var icons = PermissionIcons(mainIcon: "gear")
///     var messages = PermissionMessages(...)
///     var identifier = PermissionIdentifier(...)
///     var authStatus: AuthorizationStatus = .notDetermined
///     
///     func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
///         // Request system permission and call completion
///     }
/// }
/// ```
public protocol PermissionManagerProtocol: Equatable {
    /// Icons used to represent the permission state in the UI
    var icons: PermissionIcons { get set }
    
    /// Localized messages for permission-related UI elements
    var messages: PermissionMessages { get set }
    
    /// Unique identifier and metadata for this permission
    var identifier: PermissionIdentifier { get set }
    
    /// Current authorization status for this permission
    var authStatus: AuthorizationStatus { get set }
    
    /// Publisher for permission-related events
    var eventPublisher: PassthroughSubject<any PermissionManagerProtocol, Never> { get }
    
    /// Notifies observers of permission status changes
    func dispatchEvent()
    
    /// Requests authorization for this permission from the system
    ///
    /// - Parameter completion: Callback with the resulting authorization status
    func requestAuthorization(completion: @escaping (_ status: AuthorizationStatus) -> Void)
    
    /// Checks the current authorization status
    ///
    /// - Parameter completion: Callback with the current authorization status
    func checkAuthorization(completion: @escaping (_ status: AuthorizationStatus) -> Void)
    
    /// Returns the current authorization status asynchronously
    ///
    /// - Returns: The current authorization status
    func returnAuthorizationStatus() async -> AuthorizationStatus
    
    /// Compares this permission manager with another for equality
    ///
    /// - Parameter other: Another permission manager to compare with
    /// - Returns: True if the managers represent the same permission
    func isEqualTo(_ other: any PermissionManagerProtocol) -> Bool
}

/// Protocol for objects that need to subscribe to permission manager events.
///
/// Implement this protocol in classes that need to respond to changes in permission status
/// or other permission-related events.
///
/// Example Implementation:
/// ```swift
/// class MyPermissionObserver: PermissionManagerEventsSubscriber {
///     var permissionManagerEventSubscriber = AnyCancellable {}
///     
///     init() {
///         permissionManagerEventSubscriber = eventPublisher.sink { permission in
///             handlePermissionManagerEvent(permission)
///         }
///     }
///     
///     func handlePermissionManagerEvent(_ permission: any PermissionManagerProtocol) {
///         // Handle permission status changes
///     }
/// }
/// ```
public protocol PermissionManagerEventsSubscriber {
    /// Subscription to permission manager events
    var permissionManagerEventSubscriber: AnyCancellable { get }
    
    /// Called when a permission manager event is received
    ///
    /// - Parameter permission: The permission manager that triggered the event
    func handlePermissionManagerEvent(_ permission: any PermissionManagerProtocol)
}
