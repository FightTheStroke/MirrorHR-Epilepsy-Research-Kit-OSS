//
//  NightSupport.swift
//  
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import SwiftUI
import RoberdanToolBox
import SharedPkg

struct NightClockView: View {
    @ObservedObject var currentTime = MainTimer.shared
    @ObservedObject private var eventsManager = RealTimeEventsManager.shared

    var textColor: Color
    var isAnAlarm: Bool
    
    var body: some View {
        if isAnAlarm {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text(currentTime.now.timeClockFormatter())
                        .font(.largeTitle)
                    Text(":\(currentTime.now.secsOnly())")
                }
                .foregroundColor(.primary)
                Label(whatTimeIsNowString, systemImage: "clock")
            }
        } else {
            HStack(alignment: .center, spacing: 5) {
                VStack(spacing: 0) {
                    Text(currentTime.now.timeClockFormatter())
                        .font(.largeTitle)
                        .foregroundColor(textColor)
                    NightDimmerView(makeItSmall: true)
                }
                VStack(spacing: 5) {
                    WatchStatusView(isPortrait: false)
                    if eventsManager.showLowBatterySymbol {
                        WatchLowBatteryStatus()
                    }
                }
            }
        }
    }
}

struct NightDimmerView: View {
    @ObservedObject var settings: ProfileGenericSettings = .shared
    @State private var isEditing = false
    let makeItSmall: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            if !makeItSmall {
                Image(systemName: "sun.min")
            }
            Slider(
                value: $settings.brightness,
                in: 0...1,
                step: 0.1,
                onEditingChanged: { editing in
                    isEditing = editing
                    UIScreen.setBrightness(to: settings.brightness)
                }
            )
            Image(systemName: "sun.max")
        }
        .if(makeItSmall, transform: {
            $0.frame(width: 100)
        })
    }
}
