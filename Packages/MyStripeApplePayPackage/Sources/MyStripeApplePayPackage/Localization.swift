//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 10/03/24.
//

import Foundation

private var localStringsCache = [String: String]()

internal extension String {
    func localized() -> String {
        return NSLocalizedString(self, bundle: Bundle.module, comment: "")
    }
}
