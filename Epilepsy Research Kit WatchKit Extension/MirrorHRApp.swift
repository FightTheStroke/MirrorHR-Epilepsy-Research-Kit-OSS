//
//  MirrorHRApp.swift
//  MirrorHR WatchKit Extension
//
//  Created by Roberto D’Angelo on 24/09/2020.
//

import RoberdanToolBox
import SwiftUI

@main
struct MirrorHRApp: App {
    @StateObject private var communicationManager = CommunicationManagerWatch.shared
    @StateObject private var HRWorkout = MirrorHRWorkOut.shared
    @StateObject private var mainTimer = MainTimer.shared
    @StateObject private var mainDebugger = MainDebugger.shared

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchMainView()
                    .environmentObject(communicationManager)
                    .environmentObject(HRWorkout)
                    .environmentObject(mainTimer)
                    .environmentObject(mainDebugger)
            }
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}


