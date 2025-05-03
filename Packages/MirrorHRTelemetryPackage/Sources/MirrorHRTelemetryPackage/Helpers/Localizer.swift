//
//  Localizer.swift
//
//
//  Created by Roberto D’Angelo on 12/05/24.
//

import Foundation

internal var localStringsCache = [String: String]()

internal extension String {
    func local() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
