//
//  TelemetryDebugger.swift
//  
//
//  Created by Roberto D’Angelo on 08/08/22.
//

import Foundation
import OSLog

private let debugErrorsOnly: Bool = true
let logger = Logger(subsystem: "MirrorHR Telemetry", category: "debugLog")

public func debugLog(_ msg: String, isImportant: Bool = false, module: String = "MirrorHR Telemetry Package") {
#if DEBUG
    if isImportant {
        logger.error("Error: \(module) -> \(msg)")
    } else if !debugErrorsOnly {
        logger.log(level: .debug,"\(module) -> \(msg)")
    }
#endif
    if isImportant {
        dispatchTelemetryEvent(event: .mirrorHRError(sourceModule: module, error: msg))
    }
}
