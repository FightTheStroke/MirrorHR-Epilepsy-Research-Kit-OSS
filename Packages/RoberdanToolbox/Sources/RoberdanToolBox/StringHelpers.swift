//
//  StringHelpers.swift
//
//
//  Created by Roberto D'Angelo on 25/10/21.
//

/// String manipulation and localization helpers.
///
/// This file provides extensions to String that add common functionality
/// for text manipulation and localization support.

import Foundation

/// Cache for storing localized strings to improve performance
private var localStringsCache = [String: String]()

/// Extension providing additional string manipulation capabilities.
public extension String {
    /// Returns a localized version of the string.
    ///
    /// This method looks up the localized string using NSLocalizedString.
    /// It's a shorter alternative to NSLocalizedString with default parameters.
    ///
    /// Example Usage:
    /// ```swift
    /// let message = "welcome_message".local()
    /// ```
    ///
    /// - Returns: The localized string
    func local() -> String {
        let localized = NSLocalizedString(self, comment: "")
        return localized
    }

    /// Returns a copy of the string with its first letter capitalized.
    ///
    /// This method capitalizes only the first letter of the string,
    /// leaving the rest of the string in lowercase.
    ///
    /// Example Usage:
    /// ```swift
    /// let name = "john".capitalizingFirstLetter() // Returns "John"
    /// ```
    ///
    /// - Returns: A new string with the first letter capitalized
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + lowercased().dropFirst()
    }

    /// Capitalizes the first letter of this string in place.
    ///
    /// This method modifies the string directly, capitalizing its first
    /// letter and making the rest lowercase.
    ///
    /// Example Usage:
    /// ```swift
    /// var name = "john"
    /// name.capitalizeFirstLetter() // name is now "John"
    /// ```
    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
    
    /// Returns a truncated version of the string if it exceeds a given length.
    ///
    /// This method ensures the string is no longer than the specified length
    /// by truncating it and adding an ellipsis (...) if necessary.
    ///
    /// Example Usage:
    /// ```swift
    /// let text = "This is a long text"
    /// let short = text.truncated(to: 7) // Returns "This is..."
    /// ```
    ///
    /// - Parameter length: The maximum length of the string before truncation
    /// - Returns: The original string if it's shorter than length, or a truncated version
    func truncated(to length: Int) -> String {
        if self.count <= length {
            return self
        } else {
            let endIndex = self.index(self.startIndex, offsetBy: length)
            return String(self[..<endIndex]) + "..."
        }
    }
}
