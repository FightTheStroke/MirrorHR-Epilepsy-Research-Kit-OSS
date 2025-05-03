//
//  DebuggingTools.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 25/09/2020.
//

import Foundation
import OSLog

let debugLogger = Logger(subsystem: "Debugging", category: "PrintToConsole")
// MARK: PrintToConsole - use it instead than print as it runs only in debug mode and not on release

public func printToConsole(_ message: Any) {
    #if DEBUG
        debugLogger.log("\(String(describing: message))")
    #endif
}
