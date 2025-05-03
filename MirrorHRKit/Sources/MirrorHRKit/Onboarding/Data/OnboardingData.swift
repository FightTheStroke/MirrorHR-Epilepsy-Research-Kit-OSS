//
//  OnboardingData.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import HealthKit
import SwiftUI
import SharedPkg
import PermissionsManager

extension OnboardingWrapperViewModel {
    public static let onboardingTagsRequiringWatch: [Int] = [minBpmCard().tagNumber,
                                                             maxBPMCard().tagNumber,
                                                             alarmSoundCard().tagNumber,
                                                             notificationSoundCard().tagNumber,
                                                             parentalControlCard().tagNumber,
                                                             emergencyContactCard().tagNumber,
                                                             nightViewCard().tagNumber,
                                                             mirrorNotificationCard().tagNumber,
                                                             startFromWatchCard().tagNumber,
                                                             watchHealthCard().tagNumber,
                                                             alarmOnboardingCard().tagNumber,
                                                             rebootWatchCard().tagNumber]
    
    public static let onboardingAllCard: [OnboardingCard] = {
        [
            ciaoCard(),
            whatsNewIntroCard(),
            watchOrStreamingCard(),
            kidNameCard(),
//            videoLogV3Card(),
//            minBpmCard(),
//            maxBPMCard(),
//            askPermissionsCard(),
//            alarmSoundCard(),
//            notificationSoundCard(),
//            parentalControlCard(),
//            emergencyContactCard(),
            nightViewCard(),
            consensusCard(),
            askPermissionsCard(),
//            watchHealthCard(),
//            startFromWatchCard(),
            
            mirrorNotificationCard(),
            alarmOnboardingCard(),
            disclaimerTitleCard(),
            readyToStartCard()
        ]
    }()
    
    public static let whatsNewOnboardingData: [OnboardingCard] = {
        if OnboardingStateMachine.shared.whatsLastOnboardedVersion == "" {
            return onboardingAllCard
        } else {
            // this is at the moment just a curtesy stuff, but in the future it will help us to show specific what's new cards based on the version customer is vs actual. Es of onboardedVersion string is "8.40.4", coming from appVersion
            return [
                ciaoCard(),
                whatsNewIntroCard(),
                watchOrStreamingCard(),
                consensusCard(),
                askPermissionsCard(),
                mirrorNotificationCard(),
//                watchHealthCard(),
                rebootWatchCard(),
//                startFromWatchCard(),
//                mirrorNotificationCard(),
                disclaimerTitleCard(),
                readyToStartCard()
            ]
        }
    }()
}

// MARK: - Single Cards
extension OnboardingWrapperViewModel {
    // MARK: Ciao Card
    
    static func ciaoCard() -> OnboardingCard {
        .init(
            title: ciaoMsg,
            headline: ciaoDescriptionMsg,
            image: "mariodan",
            imageScaled2Fill: false,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "",
            form: nil,
            isLast: false,
            alignTop: true,
            tagNumber: 1
        )
    }
    
    // MARK: Watch Health Card
    static func watchHealthCard() -> OnboardingCard {
        .init(
            title: mirrorNotificationMsg,
            headline: "firstRunWatchAlertMsg".local(),
            image: "watchhealth",
            imageScaled2Fill: false,
            gradientColors: [stefiAzure.opacity(1.0), stefiAzure.opacity(0.2)],
            description: "",
            form: nil,
            isLast: false,
            alignTop: true,
            tagNumber: 101
        )
    }
    
    // MARK: Suggest restarting watch after upgrade
    static func rebootWatchCard() -> OnboardingCard {
        .init(
            title: "rebootWatchCardTitle".local(),
            headline: "rebootWatchCardHeadline".local(),
            image: "watchosrestart",
            imageScaled2Fill: false,
            gradientColors: [stefiAzure.opacity(1.0), stefiAzure.opacity(0.2)],
            description: "rebootWatchCardDescription".local(),
            form: nil,
            isLast: false,
            alignTop: true,
            tagNumber: 105
        )
    }
    
    // MARK: Disclaimer Card
    static func disclaimerForm() -> AnyView {
        AnyView(
            VStack {
                Text("AcceptingConditionsByContinuingMsg".local())
                    .padding()
                    .font(.body.bold())
                Text("SwipeRightToContinueSetupMsg")
                    .font(.caption)
                    
                Text("StopUsingMirrorHRContactUsMsg")
                    .font(.caption)
                    .padding()
            }
            .lineLimit(nil)
            .multilineTextAlignment(.center)
        )
    }
    
    static func disclaimerTitleCard() -> OnboardingCard {
        .init(
            title: disclaimerTitleMsg,
            headline: disclaimerHeadlineMsg,
            image: "",
            gradientColors: [stefiRed.opacity(1.0), stefiRed.opacity(0.2)],
            description: disclaimerDescriptionMsg,
            form: disclaimerForm(),
            isLast: false,
            alignTop: true,
            tagNumber: 2
        )
    }
    
    // MARK: NightView Card
    static func nightViewCard() -> OnboardingCard {
        .init(
            title: "nightViewCardTitle".local(),
            headline: "nightViewCardHeadline".local(),
            image: "nightview",
            imageScaled2Fill: false,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "nightViewCardDescription".local(),
            form: nil,
            isLast: false,
            alignTop: true,
            tagNumber: 103
        )
    }
    
    static func askPermissionsCard() -> OnboardingCard {
        .init(
            title: "",
            headline: "",
            image: "",
            gradientColors: [stefiRed.opacity(1.0), stefiRed.opacity(0.2)],
            description: "",
            form: AnyView(PermissionsManagerView(skippable: false)),
            isLast: false,
            alignTop: true,
            tagNumber: 14
        )
    }
    
    static func watchOrStreamingCard() -> OnboardingCard {
        .init(
            title: "HealthDataSourceSettingsView".local(),
            headline: "MirrorHRLeveragesBPMHeadline".local(),
            image: personalizeStartImage,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: personalizeStartDescription,
            form: AnyView(DataSourcePickerView()),
            isLast: false,
            alignTop: true,
            tagNumber: 3
        )
    }
    
    // MARK: Kid Name Card
    static func kidNameCard() -> OnboardingCard {
        .init(
            title: whatsUrNameMsg,
            headline: whatsUrNameHeadlineMsg,
            image: "",
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "",
            form: AnyView(AllUpPersonalInfoView(isOnboarding: true)),
            isLast: false,
            alignTop: true,
            tagNumber: 4
        )
    }
    
    // MARK: BPM Cards
    
    static func bpmForm(conditionText: String, options: [Int], binding: Binding<Int>) -> AnyView {
        AnyView(
            OnboardingPickerForm(
                currentValue: options.firstIndex(of: binding.wrappedValue) ?? 0,
                conditionText: conditionText,
                options: options,
                onChange: { index in
                    binding.wrappedValue = options[index]
                }
            )
        )
    }
    
    static func minBpmCard() -> OnboardingCard {
        .init(
            title: alarmSettingsMsg,
            headline: minBpmMsg,
            image: minBpmImage,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: minMaxBpmDescriptionMsg,
            form: bpmForm(
                conditionText: "whenBpmLowerThanMsg".local(),
                options: alarmMinOptions,
                binding: KeyFlowThresholds.binding(for: \.alarmMin)
            ),
            isLast: false,
            alignTop: true,
            tagNumber: 6
        )
    }
    
    static func maxBPMCard() -> OnboardingCard {
        .init(
            title: alarmSettingsMsg,
            headline: maxBpmMsg,
            image: maxBpmImage,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: minMaxBpmDescriptionMsg,
            form: bpmForm(
                conditionText: "whenBpmHigherThanMsg".local(),
                options: alarmMaxOptions,
                binding: KeyFlowThresholds.binding(for: \.alarmMax)
            ),
            isLast: false,
            alignTop: true,
            tagNumber: 7
        )
    }
    
    static func alarmOnboardingCard() -> OnboardingCard {
        .init(title: "alarmString".local(),
              headline: "AlarmOnboardingCardHeadline".local(),
              image: "",
              gradientColors: [stefiRed.opacity(1.0), stefiRed.opacity(0.2)],
              description: "",
              form: AnyView(AlarmSectionCard()),
              isLast: false,
              alignTop: true,
              tagNumber: 110)
    }
    
    // MARK: Alarm Card
    
    static func alarmSoundForm() -> AnyView {
        AnyView(
            OnboardingAlarmSoundPicker(
                selectionBinding: SoundOptions.binding(for: \.alarmSoundIndex),
                formTitle: "alarmSoundStyleMsg".local(),
                options: SoundOptions.shared.alarmSoundOptions,
                firstButtonText: "testAlarmSoundMsg".local(),
                firstButtonAction: testChosenSoundImmediately,
                secondButtonText: testAlarmSoundBgkMsg,
                secondButtonAction: testChosenSoundAfterThirtySecondsWithAlert,
                alert: alert
            )
        )
    }
    
    static func alarmSoundCard() -> OnboardingCard {
        .init(
            title: alarmSoundTitleMsg,
            headline: alarmSoundHeadlineMsg,
            image: alarmSoundImage,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: alarmSoundDescriptionMsg,
            form: alarmSoundForm(),
            isLast: false,
            alignTop: true,
            tagNumber: 8
        )
    }
    
    // MARK: Notification Card
    static func notificationForm() -> AnyView {
        AnyView(
            OnboardingNotificationSoundPicker(
                formTitle: "notificationSoundStyleMsg".local(),
                selectionBinding: SoundOptions.binding(for: \.notificationSoundIndex),
                options: SoundOptions.shared.notificationSoundOptions,
                buttonText: testNotificationSoundMsg,
                buttonAction: testNotificationSoundImmediately
            )
        )
    }
    
    static func notificationSoundCard() -> OnboardingCard {
        .init(
            title: notificationSoundTitleMsg,
            headline: notificationSoundHeadlineMsg,
            image: notificationSoundImage,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: notificationSoundDescriptionMsg,
            form: notificationForm(),
            isLast: false,
            alignTop: true,
            tagNumber: 9
        )
    }
    
    // MARK: Parental Control Card
    static func parentalControlForm() -> AnyView {
        AnyView(
            OnboardingToggle(
                binding: ProfileGenericSettings.shared.$parentalControl,
                toggleText: parentalControlTitleMsg
            )
        )
    }
    
    static func parentalControlCard() -> OnboardingCard {
        .init(
            title: parentalControlTitleMsg,
            headline: parentalControlHeadlineMsg,
            image: parentalControlImage,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: parentalControlDescriptionMsg,
            form: parentalControlForm(),
            isLast: false,
            alignTop: true,
            tagNumber: 10
        )
    }
    
    // MARK: Emergency Contact Card
    static func emergencyContactForm() -> AnyView {
        AnyView(
            OnboardingEmergencyContactForm(
                textFieldHeader: defaultKidName,
                textFieldBinding: ProfileGenericSettings.shared.$emergencyNumber,
                buttonText: "testCallMsg".local()
            )
        )
    }
    
    static func emergencyContactCard() -> OnboardingCard {
        .init(
            title: emergencyContactTitleMsg,
            headline: emergencyContactHeadLineMsg,
            image: emergencyContactImage,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: emergencyContactDescriptionMsg,
            form: emergencyContactForm(),
            isLast: false,
            alignTop: true,
            tagNumber: 11
        )
    }
    
    // MARK: Mirror Notification
    static func mirrorNotificationCard() -> OnboardingCard {
        .init(
            title: mirrorNotificationMsg,
            headline: mirrorNotificationsWatchMsg,
            image: "",
            imageScaled2Fill: false,
            gradientColors: [stefiRed.opacity(1.0), stefiRed.opacity(0.2)],
            description: mirrorNotificationDescriptionMsg,
            form: AnyView(OpenWatchFormView()),
            isLast: false,
            alignTop: true,
            tagNumber: 12
        )
    }
    
    static func consensusCard() -> OnboardingCard {
        .init(
            title: telemetrySectionString,
            headline: "shareAnonymizedTelemetryMsg".local(),
            image: "",
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "",
            form: AnyView(TelemetryConsensusView()),
            isLast: false,
            alignTop: true,
            tagNumber: 17
        )
    }
    
    // MARK: What's Intro New Card
    static func whatsNewIntroCard() -> OnboardingCard {
        .init(
            title: "WhatsNewInThisVersion".local() + " \(appVersion)",
            headline: "",
            image: "",
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "",
            form: AnyView(WhatsNewFeaturesListView()),
            isLast: false,
            alignTop: true,
            tagNumber: 18
        )
    }
    
    struct WhatsNewFeaturesListView: View {
        var body: some View {
            ScrollView {
                Text("version15_WhatsNewDescription".local())
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
            }
        }
    }
    
    // MARK: VideoLogV3
    static func videoLogV3Card() -> OnboardingCard {
        .init(
            title: "sympt_videoLog".local(),
            headline: "whatsNewInVideoLogV3".local(),
            image: "videoLogSample",
            imageScaled2Fill: false,
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "",
            form: nil,
            isLast: false,
            alignTop: true,
            tagNumber: 20
        )
    }
    
    static func startFromWatchCard() -> OnboardingCard {
        .init(
            title: "startFromWatchCardTitle".local(),
            headline: "startFromWatchCardHeadline".local(),
            image: "watchappstart",
            imageScaled2Fill: false,
            gradientColors: [stefiAzure.opacity(1.0), stefiAzure.opacity(0.2)],
            description: "startFromWatchCardDescription".local(),
            form: nil,
            isLast: false,
            alignTop: true,
            tagNumber: 104
        )
    }
    
    // MARK: Ready To Start Card
    static func readyToStartCard() -> OnboardingCard {
        .init(
            title: readyToStartTitleMsg,
            headline: readyToStartHeadlineMsg,
            image: readyToStartImage,
            gradientColors: [Color.purple.opacity(1), Color.purple.opacity(0.6), Color.blue.opacity(0.4), Color.blue],
            description: readyToStartDescriptionMsg,
            form: nil,
            isLast: true,
            alignTop: true,
            tagNumber: 14
        )
    }
    
    // MARK: Medication Reminders
    static func medicationReminderForm() -> AnyView {
        AnyView(
            MedicationManagerView(showHeader: true)
                .padding(.horizontal)
        )
    }
    
    static func medicationReminderCard() -> OnboardingCard {
        .init(
            title: medicationAlarmViewTitle,
            headline: "",
            image: "",
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "",
            form: medicationReminderForm(),
            isLast: false,
            alignTop: true,
            tagNumber: 13
        )
    }
    
    static func therapyOnboardingForm() -> AnyView {
        AnyView(
            TherapyEditView(showHeader: true)
        )
    }
    
    static func therapyOnboardingCard() -> OnboardingCard {
        .init(
            title: "therapiesNavTitle".local(),
            headline: "",
            image: "",
            gradientColors: [stefiViolet.opacity(1.0), stefiViolet.opacity(0.2)],
            description: "therapyOnboardingHeadline".local(),
            form: therapyOnboardingForm(),
            isLast: false,
            alignTop: true,
            tagNumber: 99
        )
    }
}

// MARK: - Helpers
extension OnboardingWrapperViewModel {
    static var alert: Alert {
        Alert(
            title: Text(importantMsg),
            message: Text("testAlarmImptMsg".local()).foregroundColor(stefiRed),
            dismissButton: .default(Text(gotItMsg))
        )
    }
    
    static func testChosenSoundImmediately() {
        mainDebugger.append("Test Alarm button pressed at \(Date().toStdString())")
        NotificationManager.shared.fireNotification(event: .testSound(critical: true, delay: 0.1), overrideLastFiredDelay: true)
    }
    
    static func testChosenSoundAfterThirtySecondsWithAlert() -> Bool {
        mainDebugger.append("Test Alarm button pressed at \(Date().toStdString())")
        NotificationManager.shared.fireNotification(event: .testSound(critical: true, delay: 30), overrideLastFiredDelay: true)
        return true
    }
    
    static func testNotificationSoundImmediately() {
        mainDebugger.append("Test notification button pressed")
        NotificationManager.shared.fireNotification(event: .testSound(critical: false, delay: 0.1), overrideLastFiredDelay: true)
    }
}

struct OpenWatchFormView: View {
    @ObservedObject var permissionManager: PermissionsManager = .shared
    
    var body: some View {
        VStack(alignment: .leading) {
            PermissionsManagerCheckView(permissionType: .notifications(isMandatory: false))
                .padding([.horizontal, .top])
            PermissionsManagerCheckView(permissionType: .criticalNotification(isMandatory: false))
                .padding(.horizontal)
            Divider()
            HStack {
                Button {
                    openWatchApp()
                } label: {
                    Label("openWatchAppMsg".local(), systemImage: "hand.point.right")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Label(mirrorNotificationsWatchMsg, systemImage: "hand.point.down")
            }
            .font(.headline)
            .foregroundStyle(Color.red)
            .padding([.horizontal, .top])
            
            Image(mirrorNotificationImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(5, antialiased: true) // Adjusted for simplified cornerRadius usage
                .edgesIgnoringSafeArea(.bottom) // Optional, if you want the image to extend into the safe area
        }
    }

    
    func openWatchApp() {
        let application = UIApplication.shared
        let url = URL(string: "itms-watchs://notifications")!
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: { success in
                if success {
                    mainDebugger.append("OpenWatchApp button opened url \(url)")
                } else {
                    mainDebugger.append("OpenWatchApp button failed to open url \(url)")
                }
            })
        }
    }
}


struct AlarmSectionCard: View {
    @ObservedObject var settings: ProfileGenericSettings = .shared
    @ObservedObject var keyFlowThresholds: KeyFlowThresholds = .shared
    @ObservedObject var soundsOptions: SoundOptions = .shared
    @State var showingAlert: Bool = false
    
    var body: some View {
        VStack {
            Section(content: {
                ForEach(alarmSection.rows) { row in
                    SettingsRowView(kind: row)
                        .padding(.vertical, 3)
                }
            })
        }
        .padding()
        .disabled(!settings.appleWatchEnabled)
        .gesture(DragGesture().onChanged({ _ in UIApplication.shared.endEditing() })) // IMPORTANT: in order to hide keyboard in an easy way
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(importantMsg),
                  message: Text("testAlarmImptMsg".local())
                    .foregroundColor(stefiRed),
                  dismissButton: .default(Text(gotItMsg)))
        }
    }
    
    var alarmSection: SettingsSection {
        SettingsSection(
            id: "Alarm",
            header: "alarmString".local(),
            image: "speaker.wave.2.circle",
            rows: [
                .custom(
                    name: "whenBpmLowerThanMsg".local(),
                    AnyView(SettingsComponents.whenBPMLowerView(parameter: $keyFlowThresholds.alarmMin))
                ),
                .custom(
                    name: "whenBpmHigherThanMsg".local(),
                    AnyView(SettingsComponents.whenBPMHigherView(parameter: $keyFlowThresholds.alarmMax))
                ),
                .custom(name: "alarmSoundStyleMsg".local(), AnyView(soundPickerView)),
                .custom(name: "testAlarmSoundBgkTitleMsg".local(), AnyView(testNotificationView))
            ]
        )
    }
                        
    var soundPickerView: some View {
        SoundsPickerView(
            parameter: $soundsOptions.alarmSoundIndex,
            optionsArray: soundsOptions.alarmSoundOptions,
            labelText: "alarmSoundStyleMsg".local()
        )
    }

    var testNotificationView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("testAlarmSoundBgkTitleMsg".local())
                    Text("rememberDuplicateNotificationsString".local()).font(.caption)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Button(action: self.testAlarm) {
                    Image(systemName: "speaker.wave.3")
                        .font(.headline)
                }
            }
            Text("CanTEarAlarmSoundGoBackMsg")
                .font(.caption)
                .foregroundColor(stefiRed)
                .padding(.vertical)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
    }
    
    func testAlarm() {
        showingAlert = true
        mainDebugger.append("Test Alarm button pressed at \(Date().toStdString())")
        dispatchMainEvent(.testSound(critical: true, delay: 30), "Test Alarm")
    }
}
