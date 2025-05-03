//
//  Speech Permissions.swift
//  
//
//  Created by Roberto D'Angelo on 02/01/23.
//

#if os(iOS)
import Foundation
import Combine
import Speech

/// A permission manager that handles speech recognition permissions using the Speech framework.
///
/// This class manages the authorization state for speech recognition capabilities,
/// including checking current status, requesting permissions, and handling authorization changes.
///
/// Important Setup Requirements:
/// - Add "Speech Recognition Usage Description" to Info.plist
/// - Configure appropriate privacy descriptions
///
/// Thread Safety:
/// - All state mutations are performed on the main thread
/// - Authorization status changes trigger events through Combine
///
/// Example Usage:
/// ```swift
/// let speechManager = SpeechPermissionManager(isMandatory: true)
/// speechManager.checkAuthorization { status in
///     // Handle authorization status
/// }
/// ```
public class SpeechPermissionManager: PermissionManagerProtocol {
    // MARK: - Properties
    
    /// Unique identifier for the speech recognition permission
    public var identifier: PermissionIdentifier
    
    /// Icons used to represent the permission state in the UI
    public var icons: PermissionIcons = PermissionIcons(mainIcon: "waveform.circle")
    
    /// Localized messages for permission-related UI
    public var messages: PermissionMessages
    
    /// Default language for speech recognition
    private let defaultPreferredLanguage: String = "en"
    
    /// Current language setting for speech recognition
    public let language: String
    
    /// Publisher for permission-related events
    public let eventPublisher = PermissionsManager.permissionManagerEventPublisher
    
    /// Current authorization status for speech recognition
    public var authStatus: AuthorizationStatus = .notDetermined {
        didSet {
            if oldValue != authStatus {
                dispatchEvent()
            }
        }
    }
    
    /// Initializes a new speech permission manager.
    ///
    /// - Parameter isMandatory: Whether this permission is required for app functionality
    public init(isMandatory: Bool) {
        identifier = PermissionIdentifier(
            name: "SpeechRecognitionLocalized".localized(),
            debugName: "Speech Recognition",
            appName: permissionsManagerAppName,
            isMandatory: isMandatory
        )
        messages = PermissionMessages(
            description: defaultDescriptionMsg(permissionName: identifier.name),
            okMessage: defaultOkMsg(),
            noOkMessage: defaultNoOkMsg(permissionName: identifier.name),
            recoveryMsg: defaultRecoveryMsg(appName: identifier.appName)
        )
        language = Locale.preferredLanguages.first ?? defaultPreferredLanguage
    }
    
    // MARK: - Event Handling
    
    /// Dispatches a permission event to notify observers of status changes
    public func dispatchEvent() {
        eventPublisher.send(self)
    }
    
    // MARK: - Authorization Status
    
    /// Checks the current authorization status for speech recognition.
    ///
    /// - Parameter completion: Callback with the current authorization status
    public func checkAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        switch authStatus {
        case .authorized:
            if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: self.language)), recognizer.isAvailable {
                self.authStatus = .authorized
            } else {
                self.authStatus = .notAvailable
            }
        case .denied:
            self.authStatus = .denied
        case .restricted:
            self.authStatus = .custom(customAuth: "Restricted")
        case .notDetermined:
            self.authStatus = .notDetermined
        @unknown default:
            self.authStatus = .unknown
        }
        completion(self.authStatus)
    }
    
    /// Returns the current authorization status asynchronously.
    ///
    /// - Returns: The current authorization status
    public func returnAuthorizationStatus() async -> AuthorizationStatus {
        do {
            let authStatus = SFSpeechRecognizer.authorizationStatus()
            switch authStatus {
            case .authorized:
                if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: self.language)), recognizer.isAvailable {
                    self.authStatus = .authorized
                } else {
                    self.authStatus = .notAvailable
                }
            case .denied:
                self.authStatus = .denied
            case .restricted:
                self.authStatus = .custom(customAuth: "Restricted")
            case .notDetermined:
                self.authStatus = .notDetermined
            @unknown default:
                self.authStatus = .unknown
            }
            return self.authStatus
        }
    }
    
    /// Requests authorization for speech recognition.
    ///
    /// - Parameter completion: Callback with the result of the authorization request
    public func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: self.language)), recognizer.isAvailable {
                    self.authStatus = .authorized
                } else {
                    self.authStatus = .authorized
                }
            case .denied:
                self.authStatus = .denied
            case .restricted:
                self.authStatus = .custom(customAuth: "Restricted")
            case .notDetermined:
                self.authStatus = .notDetermined
            @unknown default:
                self.authStatus = .unknown
            }
            completion(self.authStatus)
        }
    }
    
    // MARK: - Equatable Conformance
    
    /// Compares two speech permission managers for equality.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand side speech permission manager
    ///   - rhs: Right-hand side speech permission manager
    /// - Returns: True if the managers are equal, false otherwise
    public static func == (lhs: SpeechPermissionManager, rhs: SpeechPermissionManager) -> Bool {
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

