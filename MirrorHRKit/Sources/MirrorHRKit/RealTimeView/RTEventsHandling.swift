//
//  RTEventsHandling.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 22/12/20.
//  Copyright © 2020 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg
import RoberdanToolBox

struct RealTimeAlarmHandlingView: View {
    @ObservedObject private var eventsManager = RealTimeEventsManager.shared
    @ObservedObject private var alarm = Alarm.shared

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack {
                Spacer()
                Text(alarmMsg)
                    .font(.title2)
                Text(eventsManager.mainMessage)
                    .font(.headline).fontWeight(.bold)
                    .multilineTextAlignment(.center)
                HStack {
                    NightClockView(textColor: eventsManager.handleAlarmView ? .primary : .secondary, isAnAlarm: true)
                    Spacer()
                    StopWatchView()
                }.padding()
                HandleEventButtons()
                Spacer()
            }
        }
        .foregroundColor(.primary)
        .background(stefiViolet)
        .onAppear {
            UIScreen.setBrightness(to: 1.0)
        }
        .onDisappear {
            UIScreen.setBrightness(to: ProfileGenericSettings.shared.brightness)
        }
    }
}

struct StopWatchView: View {
    @ObservedObject private var alarm = Alarm.shared

    var body: some View {
        VStack(alignment: .center) {
            Text("\(alarm.soFar.toSmartHHMMssString())")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Label(elapsedTimeString, systemImage: "stopwatch")
        }
    }
}

struct HandleEventButtons: View {
    @EnvironmentObject var showSheet: SheetViewController
    @EnvironmentObject var settings: ProfileGenericSettings

    private var eventsManager = RealTimeEventsManager.shared
    @State var emergencyMedicationTime: Date?
//    @State var falseAlarmSaved: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showSheet.reset()
                    showSheet.navigationTitle = tagFalseAlarmTitleMsg
                    showSheet.sheetContentView = AnyView(FalseAlarmHandlingView(firingBPM: eventsManager.firingBPM))
                    showSheet.sheetVisible = true
                    showSheet.cancelActionText = ""
                    showSheet.okActionImage = ""
                    showSheet.okActionText = saveBtnMsg
                    eventsManager.alarmIsSilent = true // avoid multiple notification when it is handled
                }, label: {
                    Label(tagFalseAlarmAllGoodMsg, systemImage: "checkmark.circle.fill")
                        .font(.title2).padding(10)
                        .foregroundColor(.white)
                        .background(stefiGreen)
                        .cornerRadius(defaultBtnCornerRadius)
                })

                Spacer()

                Button(action: {
                    dispatchMainEvent(.handleSeizure(metaData: .init(name: "HANDLESEIZURE", valueString: "From HandleEventButtons")), "Handle Event Button")
                }, label: {
                    Label(tagEndOfSeizure, systemImage: HandledSymptomsEvents.seizure.image)
                        .font(.title2).padding(10)
                        .foregroundColor(.white)
                        .background(stefiRed)
                        .cornerRadius(defaultBtnCornerRadius)
                })
            }.padding([.horizontal, .bottom])

            HStack {
                Button(action: {
                    guard let number = URL(string: "tel://\(settings.emergencyNumber)") else { return }
                    UIApplication.shared.open(number)
                }, label: {
                    Label(emergencyCallLabelMsg, systemImage: "phone.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title2).padding(10)
                        .foregroundColor(.white)
                        .background(stefiPurple)
                        .cornerRadius(defaultBtnCornerRadius)
                })

                Spacer()

                Button(action: {
                    emergencyMedicationTime = .now
                    SymptomLog(.emergencyMedication)
                        .append { _ in
                            mainDebugger.append("emergency medication taken", .justALog)
                    }
                }, label: {
                    Label(emergencyMedicationTime?.toStdTime() ?? "", systemImage: HandledSymptomsEvents.emergencyMedication.image)
                        .font(.title).padding(10)
                        .foregroundColor(.white)
                        .background(stefiPurple)
                        .cornerRadius(defaultBtnCornerRadius)
                })
                
                Spacer()
                
                Button(action: {
                    let videoPicker = VideoPicker(videoType: .seizure, onDismiss: { SheetViewController.shared.sheetVisible = false })
                    let videoSeizureEvent: HandledSymptomsEvents = .videoSeizureLog
                    showSheet.reset()
                    showSheet.navigationTitle = keySettingsNavigationTitleMsg
                    showSheet.okAction = { videoPicker.stopCapture() }
                    showSheet.sheetContentView = AnyView(videoSeizureEvent.videoPickerView(videoPicker: videoPicker))
                    showSheet.cancelActionText = cancelActionMsg
                    showSheet.cancelActionImage = ""
                    showSheet.okActionImage = ""
                    showSheet.okActionText = saveSeizureMsg
                    showSheet.sheetVisible = true
                    eventsManager.alarmIsSilent = true // avoid multiple notification when it is handled
                }, label: {
                    Label(tagVideoSeizure, systemImage: "video.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title2).padding(10)
                        .foregroundColor(.white)
                        .background(stefiPurple)
                        .cornerRadius(defaultBtnCornerRadius)
                })
            }.padding(.horizontal)
        }
        .modifier(MyRoundedShadow())
    }
}

struct FalseAlarmHandlingView: View {
    @State private var notes: String = ""
    @State private var saveBtnMsg: String = saveLogMsg
    var firingBPM: Int

    var body: some View {
        VStack(alignment: .center) {
            Text(detailLogMsg).font(.headline)

            HStack {
                Text(speechHintMsg)
                Image(systemName: "mic")
            }
            .multilineTextAlignment(.leading)
            .font(.caption)

            HStack {
                Button(falseAlarmSuggestion1) {
                    notes += " " + falseAlarmSuggestion1 + notesSuggestionsSeparator
                }.padding()
                Button(falseAlarmSuggestion2) {
                    notes += " " + falseAlarmSuggestion2 + notesSuggestionsSeparator
                }.padding()
                Button(falseAlarmSuggestion3) {
                    notes += " " + falseAlarmSuggestion3 + notesSuggestionsSeparator
                }.padding()
            }
            .font(.headline)
            .padding(5)

            TextEditor(text: $notes)
                .foregroundColor(Color.primary)
                .frame(height: 150)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary).opacity(0.5))
            Spacer()
        }
        .padding()
        .onDisappear(perform: {
            UIApplication.shared.endEditing()
            dispatchMainEvent(.handleFalseAlarm(firingBPM: firingBPM, notes: notes), "False Alarm Handling View")
        })
    }
}

// struct DebugButtonsView: View {
//    @ObservedObject private var eventsManager = RealTimeEventsManager.shared
//    @ObservedObject private var alarm = Alarm.shared
//
//    var body : some View {
//        HStack {
//            Button(
//                testAlarmBtnMsg, action: {
//                    dispatchEvents(event: .alarm(metaData: ["BPM": 147]))
//                })
//
//            Button(testLowBatteryBtnMsg) {
//                dispatchEvents(event: .lowBattery(metaData: ["BatteryLevel": 45]))
//            }
//        }
//    }
// }
