//
//  AskForHelp.swift
//  
//
//  Created by Roberto D’Angelo on 27/05/23.
//

import Foundation
import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

public struct AskForHelpProxyView: View {
    @StateObject var showSheet: SheetViewController = .shared
    
    public init() {
        
    }
    
    public var body: some View {
        AskForHelpView(showSheet: $showSheet.sheetVisible)
            .onChange(of: showSheet.sheetVisible) { newValue in
                SheetViewController.shared.sheetVisible = newValue
            }
    }
}

public func ask4HelpFunction() {
    DispatchQueue.main.async {
        let showSheet: SheetViewController = .shared
        showSheet.reset()
        showSheet.cancelActionText = "cancelActionMsg".local()
        showSheet.sheetContentView = AnyView(AskForHelpProxyView())
        showSheet.sheetVisible = true
    }
}

public struct AskForHelpView: View {
    @State private var timeRemaining = 5
    @State private var isActive = true
    @State private var stopped = false
    @Binding private var showSheet: Bool
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init(showSheet: Binding<Bool>) {
        _showSheet = showSheet
    }
    
    public var body: some View {
        VStack {
            Text("sympt_ask4Help".local())
                 .font(.largeTitle)
                 .padding()

             ZStack {
                 Circle()
                     .fill(Color.red)
                     .frame(width: 200, height: 200)
                 
                 Text(isActive ? "\(timeRemaining)" : "alarmSentMsg".local())
                     .foregroundColor(.white)
                     .font(.largeTitle)
             }
            if isActive {
                Toggle(isOn: $stopped) {
                    Text(isActive ? "stopCountdownMsg".local() : "stoppedMsg".local())
                        .font(.title)
                }
                .toggleStyle(SwitchToggleStyle(tint: stopped ? .red : .green))
                .padding()
            } else {
                Text(Date().toStdString())
                    .font(.headline)
            }
         }
        .onChange(of: stopped, perform: { newValue in
            if newValue {
                self.timer.upstream.connect().cancel()
            }
            showSheet = false
        })
        .onChange(of: showSheet, perform: { newValue in
            if !newValue {
                self.timer.upstream.connect().cancel()
            }
        })
         .onReceive(timer) { _ in
             if self.isActive {
                 if self.timeRemaining > 0 {
                     self.timeRemaining -= 1
                 } else {
                     self.timer.upstream.connect().cancel()
                     self.askHelp()
                 }
             }
         }
    }
    
    func askHelp() {
        SymptomsManager.shared.fireTelemetryControlSymptoms(SymptomLog(.ask4Help, notes: "Sent a manual request for help"))
        isActive = false
        timeRemaining = 0
    }
}
