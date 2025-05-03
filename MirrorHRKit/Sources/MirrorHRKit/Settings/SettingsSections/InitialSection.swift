//
//  AboutSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg
import PermissionsManager
import MyStripeApplePayPackage

extension SettingsView {
    var donateSection: SettingsSection {
        SettingsSection(id: "DonateSection", image: "", rows: [.custom(name: "", AnyView(DonateView()), isEnabled: true)])
    }
    var initialSection: SettingsSection {
        SettingsSection(
            id: "Initial",
            header: "InformazioniPersonaliHeader".local(), //
            image: "person",
            rows: [
                .custom(name: "allUpPersonalInfo", AnyView(AllUpPersonalInfoView(isOnboarding: false)), isEnabled: true)
            ],
            foregroundColor: stefiGreen
        )
    }
    
    var complementarySupportSection: SettingsSection {
        SettingsSection(
            id: "complementarySupportSection",
            header: "faqCheckListPicker".local(),
            image: "questionmark",
            rows: [
                .custom(name: "restartOnboarding", AnyView(restartOnboarding), isEnabled: true),
                .custom(name: "INeedHelp", AnyView(iNeedHelp), isEnabled: true),
                .custom(name: "requestReviewMessage".local(), AnyView(askForRateView), isEnabled: true)
            ]
        )
    }
    
    var faqSection: SettingsSection {
        SettingsSection(
            id: "InitialSupportSection",
            header: "FrequentlyAskedQuestionsSeparator".local(),
            image: "questionmark",
            rows: [
                .custom(name: checkPermissionsString, AnyView(CheckPermissionsView())),
                .custom(name: "healthPermissionsFAQTask", AnyView(FAQView(webUrl: "https://support.apple.com/en-us/HT204351", title: "healthPermissionsFAQTask"))),
                .custom(name: "watchConnectivityFAQTask", AnyView(FAQView(webUrl: "https://support.apple.com/en-us/HT204562", title: "watchConnectivityFAQTask"))),
                .custom(name: "permissionsCheckFaq", AnyView(permissionsCheckFaq)),
                .custom(name: "mirrorHRUserFlowTask", AnyView(FAQView(webUrl: "https://www.fightthestroke.org/mirrorhr-eng", title: "mirrorHRUserFlowTask"))),
                .custom(name: "knowMoreWHOTask", AnyView(FAQView(webUrl: "https://www.who.int/news-room/fact-sheets/detail/epilepsy", title: "knowMoreWHOTask"))),
                .custom(name: "mirrorHRHistoryTask", AnyView(FAQView(webUrl: "https://www.fightthestroke.org/mirrorhr-eng", title: "mirrorHRHistoryTask")))
            ],
            foregroundColor: stefiBlue
        )
    }
    
    var restartOnboarding: some View {
        AnyView(
            HStack {
                Button {
                    OnboardingStateMachine.shared.setOnboarding(to: true)
                } label: {
                    Label(restartOnboardingMsg, systemImage: "restart")
                        .labelStyle(ColorfulIconLabelStyle(color: stefiGreen, size: size))
                }
                .multilineTextAlignment(.leading)
                Spacer()
            }
        )
    }
    
    var iNeedHelp: some View {
        AnyView(
            HStack {
                Button {
                    if let url = URL(string: "contactLinkDestination".local()) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("doYouNeedHelpString".local(), systemImage: "questionmark")
                        .labelStyle(ColorfulIconLabelStyle(color: stefiGreen, size: size))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
        )
    }
    
    var joinCommunity: some View {
        AnyView(
            HStack {
                Button {
                    if let url = URL(string: "https://www.fightthestroke.org/mirrorhr-eng") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("joinMirrorHRCommunityTask".local(), systemImage: "questionmark")
                        .labelStyle(ColorfulIconLabelStyle(color: stefiGreen, size: size))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
        )
    }
    
    var permissionsCheckFaq: some View {
        AnyView(
            HStack {
                NavigationLink {
                    PermissionsCheckFaqView()
                        .modifier(MyRadialViewModifier(isList: true))

                } label: {
                    Label("permissionsCheckFaq".local(), systemImage: "questionmark")
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.accentColor)
                }
                Spacer()
            }
        )
    }
    
    var supportMirrorHR: some View {
        AnyView(
            HStack {
                Button {
                    if let url = URL(string: "https://www.fightthestroke.org/donorboxeng") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("supportMirrorHRTak".local(), systemImage: "hands.sparkles")
                        .font(.body.bold())
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
        )
    }
}

struct KidNameSettingsView: View {
    @ObservedObject var settings = ProfileGenericSettings.shared
    @State private var isEditing: Bool = false
    let fieldName = nameString
    
    var body: some View {
        VStack {
            HStack {
                Text(fieldName)
                Spacer()
                Text(settings.kidName)
                    .font(.body.bold())
                if isEditing {
                    Button {
                        UIApplication.shared.endEditing()
                        isEditing = false
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .font(.body.bold())
                    }
                } else {
                    Button {
                        isEditing = true
                    } label: {
                        Image(systemName: chevronDown)
                            .font(.body.bold())
                    }
                }
            }
            if isEditing {
                MyTextField(fieldName: fieldName, bindingString: $settings.kidName, isMandatory: true, split2Rows: false, showFieldName: false, textAlignment: .center, frameWidth: nil)
            }
        }
    }
}

struct KidBirthDateView: View {
    @Binding var kidBirthDate: Date
    
    var body: some View {
        VStack {
            DatePicker(selection: $kidBirthDate, in: ...Date(), displayedComponents: [.date]) {
                Text("kidDateOfBirthString".local() + ":")
            }
        }
    }
}

struct KidAgeView: View {
    @Binding var birthDate: Date
    
    var body: some View {
        VStack {
            HStack {
                Text("kidAgeString".local() + ":")
                Spacer()
                Text(ProfileGenericSettings.shared.calculateKidAge(birthDate: birthDate)?.text ?? "")
                    .font(.body.bold())
            }
        }
    }
}

struct FAQView: View {
    var webUrl: String
    var title: String
    
    var body: some View {
        HStack {
            Button {
                if let url = URL(string: webUrl) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(title.local(), systemImage: "questionmark")
                .multilineTextAlignment(.leading)               }
            Spacer()
        }
    }
}

public struct PermissionsCheckFaqView: View {
    public init() {
    }
    
    public var body: some View {
        ScrollView {
            Text("firstRunWatchAlertMsgExtended".local())
                .multilineTextAlignment(.leading).lineLimit(nil).fixedSize(horizontal: false, vertical: true)
            Image("watchhealth")
                .resizable()
                .scaledToFit()
        }
        .padding()
    }
}

public struct CheckPermissionsView: View {
    private let settings: ProfileGenericSettings = .shared
    
    public var body: some View {
        VStack {
            NavigationLink {
                PermissionsManagerView(skippable: false)
                    .modifier(MyRadialViewModifier(isList: true))

            } label: {
                Label(checkPermissionsString.local(), systemImage: "key")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.accentColor)
            }
            Spacer()
        }
    }
}

public struct AllUpPersonalInfoView: View {
    @ObservedObject private var settings: ProfileGenericSettings = ProfileGenericSettings.shared
    @Environment(\.dismiss) var dismiss
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    @State private var showWeightPickers: Bool = false
    @State private var showEpilepsyTypePicker: Bool = false
    var isOnboarding: Bool

    public init(isOnboarding: Bool) {
        self.isOnboarding = isOnboarding
    }
    
    public var body: some View {
        if isOnboarding {
            VStack {
                MyTextField(fieldName: "nameString".local(), bindingString: $settings.kidName, isMandatory: false)
                Divider()
                BirthDateView(kidBirthDate: $settings.kidBirthDate)
                Divider()

                KidWeightView(
                    kidWeight: $settings.kidWeight,
                    measurementUnit: $settings.measurementsUnit,
                    showWeightPickers: $showWeightPickers,
                    showEpilepsyTypePicker: $showEpilepsyTypePicker
                )
                Divider()

                EpilepsyTypeView(epilepsyType: $settings.epilepsyType, showEpilepsyTypePicker: $showEpilepsyTypePicker, showWeightPickers: $showWeightPickers)
                Divider()

                MyTextField(fieldName: "doctorsEmailString".local(), bindingString: $settings.doctorEmail, isMandatory: false, split2Rows: true, textAlignment: .center, keyboardType: .emailAddress)
                Divider()

                MyTextField(fieldName: "emergencyContactTitleMsg".local(), bindingString: $settings.emergencyNumber, isMandatory: false, split2Rows: true, textAlignment: .center, keyboardType: .phonePad)
            }
            .padding()
        } else {
            List {
                MyTextField(fieldName: "nameString".local(), bindingString: $settings.kidName, isMandatory: false)
                BirthDateView(kidBirthDate: $settings.kidBirthDate)
                KidWeightView(
                    kidWeight: $settings.kidWeight,
                    measurementUnit: $settings.measurementsUnit,
                    showWeightPickers: $showWeightPickers,
                    showEpilepsyTypePicker: $showEpilepsyTypePicker
                )
                EpilepsyTypeView(epilepsyType: $settings.epilepsyType, showEpilepsyTypePicker: $showEpilepsyTypePicker, showWeightPickers: $showWeightPickers)
                MyTextField(fieldName: "doctorsEmailString".local(), bindingString: $settings.doctorEmail, isMandatory: false, split2Rows: true, textAlignment: .center, keyboardType: .emailAddress)
                MyTextField(fieldName: "emergencyContactTitleMsg".local(), bindingString: $settings.emergencyNumber, isMandatory: false, split2Rows: true, textAlignment: .center, keyboardType: .phonePad)
            }
            .listStyle(.automatic)
            .modifier(MyRadialViewModifier(isList: true))
        }
    }
}

struct BirthDateView: View {
    @Binding var kidBirthDate: Date
    
    init(kidBirthDate: Binding<Date>) {
        self._kidBirthDate = kidBirthDate
    }

    var body: some View {
        VStack {
            DatePicker(selection: $kidBirthDate, in: ...Date(), displayedComponents: [.date]) {
                Text("kidDateOfBirthString".local() + ":")
            }
            HStack {
                Text("kidAgeString".local() + ":")
                Spacer()
                // Assuming `calculateKidAge` can be called in a static context or you adjust accordingly
                Text(ProfileGenericSettings.shared.calculateKidAge(birthDate: kidBirthDate)?.text ?? "")
                    .fontWeight(.bold)
            }
        }
    }
}

struct KidWeightView: View {
    @Binding var kidWeight: Double
    @Binding var measurementUnit: MeasurementsUnit
    @Binding var showWeightPickers: Bool
    @Binding var showEpilepsyTypePicker: Bool

    var body: some View {
        VStack {
            HStack {
                Text("kidWeightString".local())
                Spacer()
                Text(String(format: "%.2f", kidWeight))
                    .fontWeight(.bold)
                Text(measurementUnit.weightUnit)
                Image(systemName: showWeightPickers ? chevronUP : chevronDown)
                    .foregroundColor(.accentColor)
                    .font(.body.bold())
                    .onTapGesture {
                        self.showWeightPickers.toggle()
                        if self.showWeightPickers, self.showEpilepsyTypePicker {
                            self.showEpilepsyTypePicker = false
                        }
                    }
            }
            if showWeightPickers {
                HStack {
                    MyDoubleFieldPicker(fieldName: "", bindingDouble: $kidWeight, isMandatory: false)
                    Spacer()
                    Picker("", selection: $measurementUnit) {
                        ForEach(MeasurementsUnit.allCases, id: \.self) { unit in
                            Text("\(unit.weightUnit)")
                                .fontWeight(measurementUnit == unit ? .bold : .regular)
                        }
                    }
                    .pickerStyle(.wheel) // Adjust picker style as necessary
                    .clipped()
                }
                .frame(height: 150)
                .textFieldStyle(.roundedBorder)
            }
        }
    }
}

private struct EpilepsyTypeView: View {
    @Binding var epilepsyType: EpilepsyType
    @Binding var showEpilepsyTypePicker: Bool
    @Binding var showWeightPickers: Bool // This is needed to toggle the weight pickers from this view

    var body: some View {
        VStack {
            HStack {
                Text("epilepsyTypeString".local() + ":")
                Spacer()
                Image(systemName: showEpilepsyTypePicker ? chevronUP : chevronDown)
                    .foregroundColor(.accentColor)
                    .font(.body.bold())
                    .onTapGesture {
                        showEpilepsyTypePicker.toggle()
                        if showWeightPickers, showEpilepsyTypePicker {
                            showWeightPickers = false
                        }
                    }
            }
            if showEpilepsyTypePicker {
                Picker("", selection: $epilepsyType) {
                    ForEach(EpilepsyType.allCases, id: \.self) { type in
                        Text("\(type.description)")
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fontWeight(epilepsyType == type ? .bold : .regular)
                    }
                }
                .pickerStyle(.wheel) // Specify the picker style if necessary
                .clipped()
                .frame(height: 150)
            } else {
                Text(epilepsyType.description)
                    .font(.body)
                    .fontWeight(.bold)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom)
            }
        }
    }
}
