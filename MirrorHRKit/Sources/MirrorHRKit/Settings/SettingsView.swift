//
//  ProfileView.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 25/09/2020.
//

import Combine
import SwiftUI
import SharedPkg
import MyStripeApplePayPackage
import Stripe
import MirrorHRTelemetryPackage

// MARK: - Section Definition
extension SettingsView {
    var sections: [SettingsSection] {
        [
            mainDataSourceSection,
            alarmSection,
            notificationSection,
            sleepSection,
            currentTherapySection,
            medicationReminderSection,
            faqSection,
            researchSection,
            aboutSectionStuff
        ]
    }
    
    struct MainSettingsSection {
        var id: String
        var sections: [SettingsSection]
    }
    
    var donationSection: MainSettingsSection { MainSettingsSection(id: "Donation", sections: [donateSection])}
    var personalSection: MainSettingsSection { MainSettingsSection(id: "AboutYouPersonalSettingsSection".local() + ": " + viewModel.settings.kidName, sections: [initialSection])}
    var settingsSection: MainSettingsSection { MainSettingsSection(id: "SettingsSettingsSection".local(), sections: [ mainDataSourceSection, alarmSection, notificationSection, remoteNotificationsSettingsSection,sleepSection])}
    var medicalPlanSection: MainSettingsSection { MainSettingsSection(id: "MedicalPlanSettingsSection".local(), sections: [currentTherapySection, medicationReminderSection])}
    var aboutSection: MainSettingsSection { MainSettingsSection(id: "AboutMirrorHRSettingsSection".local(), sections: [backupRestoreSection, faqSection, researchSection, aboutSectionStuff])}
    
    var mainSections: [MainSettingsSection] { [settingsSection, medicalPlanSection, aboutSection]}
}

struct SectionView: View {
    var section: SettingsSection
    
    init(section: SettingsSection) {
        self.section = section
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        Form {
            Section(
                footer: Text(section.footer ?? "")
                    .lineLimit(nil)
            ) {
                ForEach(section.rows) { row in
                    SettingsRowView(kind: row)
                }
            }
            .disabled(!section.isEnabled)
        }
        .listStyle(.automatic)
        .navigationTitle(section.header ?? "")
        .navigationBarTitleDisplayMode(.automatic)
        .gesture(DragGesture().onChanged({ _ in UIApplication.shared.endEditing() })) // IMPORTANT: in order to hide keyboard in an easy way
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var dataSourceManager: DataSourceManager
    @ScaledMetric var size: CGFloat = 1
    
    init(viewModel: SettingsViewModel = .shared,
         dataSourceManager: DataSourceManager = .shared) {
        self.viewModel = viewModel
        self.dataSourceManager = dataSourceManager
    }
    
    var settingsList: some View {
        List {
            Section {
                restartOnboarding
                HelpMeView(useCustomLabelStyle: true)
                askForRateView
            }
            
            Section {
                NavigationLink(destination: AllUpPersonalInfoView(isOnboarding: false)
                    .modifier(MyRadialViewModifier(isList: true))

                    .navigationTitle("InformazioniPersonaliHeader".local())) {
                    Label("InformazioniPersonaliHeader".local(), systemImage: "person.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: stefiGreen, size: 1.0))
                }
            }
            
            ForEach(self.mainSections, id: \.id) { mainSection in
                Section {
                    ForEach(mainSection.sections) { section in
                        NavigationLink(destination: SectionView(section: section)                    .modifier(MyRadialViewModifier(isList: true))
) {
                            HStack {
                                Label(section.header?.capitalizingFirstLetter() ?? "", systemImage: section.image)
                                    .labelStyle(ColorfulIconLabelStyle(color: section.foregroundColor ?? .accentColor, size: size))
                                
                                if section.id == "mainDataSourceSection", dataSourceManager.dataSourceHasErrors {
                                    Spacer()
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .font(.body.bold())
                    }
                }
            }
            if StripeAPI.deviceSupportsApplePay() {
                Section() {
                    DonateView()
                }
            }
        }
        .listStyle(.automatic) // Leave off for sticky headers
    }
    
    var body: some View {
        NavigationView {
            VStack {
                settingsList
                    .modifier(MyRadialViewModifier(isList: true))
            }
            .font(.body)
            .navigationTitle(Tab.settings.title)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(shortAppName + " " + appVersion)
                        .foregroundColor(.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HelpMeView(useCustomLabelStyle: false)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .alert(isPresented: self.$viewModel.showingAlert) {
            Alert(title: Text(importantMsg),
                  message: Text("testAlarmImptMsg".local())
                .foregroundColor(.red),
                  dismissButton: .default(Text(gotItMsg)))
        }
//        .onChange(of: settings.watchStreamingStatus) { newValue in
//            DispatchQueue.main.async {
//                showStreamingResetHeader = newValue == .streamOnlyAsClient
//            }
//        }
    }
}

func migrateDB(_ completion: @escaping (_ done: Bool) -> Void) {
    mainDebugger.append("migrating DB", .event)
    completion(true)
}
