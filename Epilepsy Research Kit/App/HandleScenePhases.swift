//
//  HandleScenePhases.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 31/08/22.
//  Copyright © 2022 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg
import MirrorHRKit

private var keepItAliveBgTask: UIBackgroundTaskIdentifier = .invalid

internal func handleScenePhases(_ phase: ScenePhase) {
    switch phase {
    case .background:
        keepItAliveBgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            cleanUp()
        })
    case .inactive:
        break
    case .active:
        UIApplication.shared.endBackgroundTask(keepItAliveBgTask)
        mainDebugger.append("MirrorHR is active")
    @unknown default:
        mainDebugger.append("MirrorHR is in unknown phase for SchenePhase", .error, sourceModule: "handleScenePhases")
    }
}

internal func cleanUp() {
    // do wathever it takes to clean up the session
    UIApplication.shared.endBackgroundTask(keepItAliveBgTask)
#if DEBUG
    print("I'm in the clean up function")
#endif
}
