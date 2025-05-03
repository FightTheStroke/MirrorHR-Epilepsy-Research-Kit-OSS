//
//  iPhoneBatteryRelated.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 02/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg

public class CheckiPhoneBatteryTimer: ObservableObject {
    public static let shared = CheckiPhoneBatteryTimer()
    @Published var iPhoneBatteryStatus: Int = 0
    private let checkInterval: TimeInterval = 900 // check battery status every 15 minutes (= 900 seconds)
    
    private init() {
        // initial check
        DispatchQueue.main.async {
            self.iPhoneBatteryStatus = checkBatteryStatus()
            mainDebugger.append("Initial iPhone Battery: " + "\(self.iPhoneBatteryStatus)")
        }

        
        Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                self.iPhoneBatteryStatus = checkBatteryStatus()
                mainDebugger.append("iPhone battery check: \(self.iPhoneBatteryStatus)", .justALog)
            }
        }
    }
}

func checkBatteryStatus() -> Int {
    let batteryPercentage = Int(UIDevice.current.batteryLevel * 100)

    if batteryPercentage <= 20, batteryPercentage > 0 { // > 0 prevent it fires on simulator
        let metaData: EventMetaData = .init(name: "BatteryLevel", valueInt: Int(batteryPercentage))
        NotificationManager.shared.fireNotification(event: .lowBatteryIphone(metaData: metaData), overrideLastFiredDelay: true)
        mainDebugger.append("Battery Level on iPhone is very low! \(batteryPercentage)", .event)
    }
    return Int(batteryPercentage)
}
