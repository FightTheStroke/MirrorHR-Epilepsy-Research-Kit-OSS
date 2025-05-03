//
//  Reset.swift
//  
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import Foundation
import SharedPkg

public extension LocalStreamingManager {
    // in compliance with ResettableToDefaultSetting Protocol
    func reset() {
        mainDebugger.append("ResetToDefaultValuesPublisher event received from StreamingManager class", .event)
        isEnabled = false
        isServer = false
        isClient = false
    }
}
