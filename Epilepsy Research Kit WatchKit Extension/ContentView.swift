//
//  ContentView.swift
//  MirrorHR WatchKit Extension
//
//  Created by Roberto D’Angelo on 24/09/2020.
//

import SharedPkg
import SwiftUI
import RoberdanToolBox

// IMPT: main content view on watch
let stefiViolet: Color = .purple

struct WatchMainView: View {
    @EnvironmentObject var hRWorkout: MirrorHRWorkOut
    
    var body: some View {
        VStack(spacing: 0) {
            BatteryView()
            Spacer()
            if case .error(let description) = hRWorkout.workOutState {
                ErrorMsgView(message: description)
            } else {
                switch hRWorkout.healthAuthorizationStatus {
                case .authorized:
                    WatchRunningView()
                         .environmentObject(hRWorkout)
                case .notDetermined:
                    AskPermissionsButtonView()
                        .environmentObject(hRWorkout)
                case .denied:
                    ErrorMsgView(message: "cantWorkWithoutHealthAccessMessage".local())
                case .notAvailable, .error, .custom, .unknown:
                    ErrorMsgView(message: "Health Data Error: \(hRWorkout.healthAuthorizationStatus.localizedDescription)".local())
                }
            }
        }
    }
}

struct ErrorMsgView: View {
    let message: String
    
    var body: some View {
        ScrollView {
            Image("MirrorShield25")
            Text(message)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
        }
    }
}



struct AskPermissionsButtonView: View {
    @EnvironmentObject var hRWorkout: MirrorHRWorkOut

    var body: some View {
        ScrollView {
            Image("MirrorShield25")
            Button {
                hRWorkout.checkPermissions()
            } label: {
                Label("GrantAllPermissionsCarefullyMessage".local(), systemImage: "lock.open")
                    .foregroundColor(.green)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
            }
            Text("GrantAllPermissionsCarefullyMessagePart2".local())
                .foregroundColor(.accentColor)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
        }
    }
}

struct WatchRunningView: View {
    @EnvironmentObject var hRWorkout: MirrorHRWorkOut

    var body: some View {
        VStack {
            switch hRWorkout.workOutState {
            case .running:
                MainBPMViewWatch()
            case .stopped, .delayedStop:
                HStack {
                    Image("MirrorShield25")
                    Text(offLabelMsg)
                        .font(.title).fontWeight(.black)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.secondary)
                }
            case .error(let description):
                Text("\(description)")
                    .foregroundColor(.red)
            }
            Spacer()
            WatchButtonView()
                .environmentObject(hRWorkout)
        }
    }
}

struct WatchButtonView: View {
    @EnvironmentObject var hRWorkout: MirrorHRWorkOut
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                VStack {
                    if case .running = hRWorkout.workOutState {
                        if hRWorkout.parentalControl {
                            Text(parentalControlOnString)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.secondary)
                        } else {
                            Text(stopMsg)
                            Text(tap3timesMsg)
                                .font(.caption)
                        }
                    } else {
                        Text(startMsg)
                        Text(tap3timesMsg)
                            .font(.caption)
                    }
                }
                .font(.headline)
            }
            
            VStack {
                if case .running = hRWorkout.workOutState {
                    if hRWorkout.parentalControl {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color.secondary)
                    } else {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                } else {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        .foregroundColor(Color.primary)
        .overlay(
            RoundedRectangle(cornerRadius: defaultBtnCornerRadius)
                .stroke(Color.secondary, lineWidth: hRWorkout.parentalControl ? 0 : 2)
        )
        .cornerRadius(defaultBtnCornerRadius)
        .onTapGesture(count: 3) {
            switch hRWorkout.workOutState {
            case .running:
                hRWorkout.workOutState = .stopped(source: .appleWatch)
            case .stopped:
                hRWorkout.workOutState = .running(source: .appleWatch)
            case .error:
                // try to recover from an error
                hRWorkout.workOutState = .running(source: .appleWatch)
            case .delayedStop:
                hRWorkout.workOutState = .running(source: .appleWatch)
            }
        }
    }
}

// TODO: change BPM text color based on events/status -> need params also on the watch, also for the parental control avoiding to stop from watch

struct MainBPMViewWatch: View {
    @EnvironmentObject var session: CommunicationManagerWatch
    @EnvironmentObject var hRWorkout: MirrorHRWorkOut
    @EnvironmentObject var currentTime: MainTimer
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                
                if hRWorkout.bpmFromWatch.bpm == 0 {
                    ProgressView()
                        .scaleEffect(2, anchor: .center)
                } else {
                    Text("\(hRWorkout.bpmFromWatch.bpm)")
                        .font(.title).fontWeight(.black)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.primary)
                }
                
                Spacer()
                
                VStack {
                    Text(bPmLabelMsg)
                    Image(systemName: "heart.fill")
                    if case .running = hRWorkout.workOutState {
                        Text("\(hRWorkout.bpmFromWatch.intervalSinceLast.toSmartHHMMssString()) s")
                            .foregroundColor(Color.secondary)
                    } else {
                        Text("(\(appName) \(Text(appVersion)))")
                            .foregroundColor(Color.secondary)
                    }
                }
                .foregroundColor(Color.secondary)
                .font(.caption)
            }
        }
        .padding(.horizontal)
    }
}
