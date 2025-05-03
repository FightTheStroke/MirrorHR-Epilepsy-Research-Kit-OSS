//
//  Permissions Manager Constants.swift
//  
//
//  Created by Roberto D'Angelo on 02/01/23.
//

/// Constants and helper functions for the PermissionsManager framework.
///
/// This file contains default values and message formatting functions used
/// throughout the framework to maintain consistent messaging and behavior.

import Foundation

/// Default application name used when no specific name is provided.
/// Retrieved from localization with key "ThisAppNameString".
internal var defaultAppName4PermissionsManager: String = "ThisAppNameString".localized()

/// Default support email address for permission-related inquiries.
internal var defaultSupportEmail = "helpme@mirrorhr.org"

/// Current application name used in permission requests.
/// Initialized with the default app name but can be updated during personalization.
internal var permissionsManagerAppName: String = defaultAppName4PermissionsManager

/// Generates a recovery message for when permission is denied.
///
/// This message provides instructions to the user on how to enable
/// the permission through system settings.
///
/// - Parameter appName: Name of the application requesting permission
/// - Returns: Localized recovery message with the app name inserted
internal func defaultRecoveryMsg(appName: String) -> String {
    return "RecoveryMsgLocalizePart1".localized() + " \(appName) " + "RecoveryMsgLocalizePart2".localized()
}

/// Generates a description message explaining why a permission is needed.
///
/// This message helps users understand why the app is requesting
/// a particular permission.
///
/// - Parameter permissionName: Name of the permission being requested
/// - Returns: Localized description message with the permission name inserted
internal func defaultDescriptionMsg(permissionName: String) -> String {
    return "DescriptionMsgPart1".localized() + " \(permissionName) " + "DescriptionMsgPart2".localized()
}

/// Generates a message for when permission is not granted.
///
/// This message informs users about the implications of not granting
/// a particular permission.
///
/// - Parameter permissionName: Name of the permission that was denied
/// - Returns: Localized message with the permission name inserted
internal func defaultNoOkMsg(permissionName: String) -> String {
    return "NoOkMessagePart1".localized() + " \(permissionName), " + "NoOkMessagePart2".localized()
}

/// Returns a standard acknowledgment message.
///
/// This message is used to confirm that a permission has been granted.
///
/// - Returns: Localized acknowledgment message
internal func defaultOkMsg() -> String {
    return "OKMessageLocalized".localized()
}


