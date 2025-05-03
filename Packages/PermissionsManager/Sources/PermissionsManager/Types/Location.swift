//
//  LocationPermissionManager.swift
//
//
//  Created by Roberto D'Angelo on 16/06/24.
//

import Foundation
import Combine
import CoreLocation

/// A permission manager that handles location services permissions using CoreLocation.
///
/// This class manages the authorization state for location services, including:
/// - When-in-use location access
/// - Location authorization status monitoring
/// - Automatic status updates through CLLocationManagerDelegate
///
/// Important Setup Requirements:
/// - Add appropriate privacy descriptions to Info.plist:
///   - NSLocationWhenInUseUsageDescription
///   - NSLocationAlwaysAndWhenInUseUsageDescription (if needed)
///
/// Thread Safety:
/// - All state mutations are performed on the main thread
/// - Location manager delegate callbacks are handled safely
///
/// Example Usage:
/// ```swift
/// let locationManager = LocationPermissionManager(isMandatory: true)
/// locationManager.checkAuthorization { status in
///     // Handle authorization status
/// }
/// ```
public class LocationPermissionManager: NSObject, PermissionManagerProtocol, CLLocationManagerDelegate {
    // MARK: - Properties
    
    /// Unique identifier for the location services permission
    public var identifier: PermissionIdentifier
    
    /// Icons used to represent the permission state in the UI
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "location.circle")
    
    /// Localized messages for permission-related UI
    public var messages: PermissionMessages
    
    /// Default language for localization
    private let defaultPreferredLanguage: String = "en"
    
    /// Current language setting
    public var language: String
    
    /// Publisher for permission-related events
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    /// Current authorization status for location services
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    /// Core Location manager instance
    private var locationManager: CLLocationManager
    
    /// Initializes a new location permission manager.
    ///
    /// - Parameter isMandatory: Whether this permission is required for app functionality
    public init(isMandatory: Bool) {
        self.locationManager = CLLocationManager()
        self.identifier = PermissionIdentifier(
            name: NSLocalizedString("LocationServicesLocalized", comment: ""),
            debugName: "Location Services",
            appName: permissionsManagerAppName,
            isMandatory: isMandatory
        )
        self.messages = PermissionMessages(
            description: defaultDescriptionMsg(permissionName: identifier.name),
            okMessage: defaultOkMsg(),
            noOkMessage: defaultNoOkMsg(permissionName: identifier.name),
            recoveryMsg: defaultRecoveryMsg(appName: identifier.appName)
        )
        self.language = Locale.preferredLanguages.first ?? defaultPreferredLanguage
        
        super.init()
        self.locationManager.delegate = self
    }
    
    // MARK: - Event Handling
    
    /// Dispatches a permission event to notify observers of status changes
    public func dispatchEvent() {
        eventPublisher.send(self)
    }
    
    // MARK: - Authorization Management
    
    /// Requests authorization for when-in-use location access.
    ///
    /// - Parameter completion: Callback with the result of the authorization request
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Returns the current authorization status asynchronously.
    ///
    /// - Returns: The current authorization status
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        updateAuthStatus()
        return authStatus
    }
    
    /// Checks the current authorization status for location services.
    ///
    /// - Parameter completion: Callback with the current authorization status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        updateAuthStatus()
        completion(authStatus)
    }
    
    /// Updates the internal authorization status based on CLLocationManager's status.
    private func updateAuthStatus() {
        switch CLLocationManager().authorizationStatus {
        case .notDetermined:
            authStatus = .notDetermined
        case .restricted, .denied:
            authStatus = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            authStatus = .authorized
        @unknown default:
            authStatus = .unknown
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// Handles changes in location authorization status.
    ///
    /// - Parameter manager: The location manager that triggered the change
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthStatus()
    }
    
    // MARK: - Equatable Conformance
    
    /// Compares two location permission managers for equality.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand side location permission manager
    ///   - rhs: Right-hand side location permission manager
    /// - Returns: True if the managers are equal, false otherwise
    public static func == (lhs: LocationPermissionManager, rhs: LocationPermissionManager) -> Bool {
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
