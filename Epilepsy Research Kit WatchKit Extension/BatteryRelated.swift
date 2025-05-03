//
//  BatteryRelated.swift
//  MirrorHR WatchKit Extension
//
//  Created by Roberto D’Angelo on 21/10/2020.
//

import Foundation
import SharedPkg
import SwiftUI

let lowBatteryImg = "battery.25"
let fullBatteryImg = "battery.100"

extension CommunicationManagerWatch {
    func checkBatteryStatus() -> Int {
        let batteryPercentage: Float
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        batteryPercentage = WKInterfaceDevice.current().batteryLevel * 100
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
        let sessionMessage = SessionMessage(command: .battery(batteryLevel: batteryPercentage, timestamp: Date().timeIntervalSince1970))
        sendMessage(message: sessionMessage.messageDictionary())
        mainDebugger.append("Battery level sent to the main app (\(batteryPercentage))")
        if batteryPercentage <= 3.0 {
            mainDebugger.append("Battery Level is very low! \(batteryPercentage)", .justALog)
        }
        return Int(batteryPercentage)
    }
}

struct BatteryView: View {
    @ObservedObject var communicationManager: CommunicationManagerWatch = .shared
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                if communicationManager.batteryStatus > 65 {
                    Image(systemName: "battery.100")
                } else {
                    Image(systemName: lowBatteryImg)
                }
                Text(" \(communicationManager.batteryStatus)%")
            }
            .foregroundColor(communicationManager.batteryStatus < 25 ? .red : Color.secondary)
            Spacer()
            Text("v\(Text(appVersion))")
                .foregroundColor(Color.secondary)
        }
    }
}
