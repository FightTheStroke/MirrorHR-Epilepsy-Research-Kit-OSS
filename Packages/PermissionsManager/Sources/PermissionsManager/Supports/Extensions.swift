//
//  Permissions Manager Extensions.swift
//  
//
//  Created by Roberto D'Angelo on 04/01/23.
//

/// Extensions for the PermissionsManager framework.
///
/// This file contains extensions to standard types that provide additional
/// functionality needed by the framework, particularly for localization.

import Foundation

/// Cache for storing localized strings to improve performance
private var localStringsCache = [String: String]()

/// Extension to String providing localization support.
internal extension String {
    /// Returns a localized version of the string using the framework's bundle.
    ///
    /// This method looks up the localized string in the framework's bundle
    /// using the current string as the key. It uses a cache to improve
    /// performance for frequently accessed strings.
    ///
    /// Example Usage:
    /// ```swift
    /// let message = "welcome_message".localized()
    /// ```
    ///
    /// - Returns: The localized string from the framework's bundle
    func localized() -> String {
        return NSLocalizedString(self, bundle: Bundle.module, comment: "")
    }
}
