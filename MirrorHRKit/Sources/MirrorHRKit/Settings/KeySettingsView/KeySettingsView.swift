//
//  KeySettingsView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 28/01/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg

extension KeySettingsView {
    class KeySettingsViewModel: ObservableObject {
        static var shared: KeySettingsViewModel = KeySettingsViewModel()
        
        @Published var sheetView: SheetViewController = .shared
        @Published var keyFlowThresholds: KeyFlowThresholds = .shared
        @Published var settings: ProfileGenericSettings = .shared
        @Published var soundOptions: SoundOptions = .shared
        @ObservedObject var tabViewController: TabViewController = .shared
        @ObservedObject internal var dataSourceManager: DataSourceManager = .shared
        
        func sampleChartDataPressed() {
            sampleChartActionDebug1()
            sheetView.sheetVisible.toggle()
        }

        func openAllSettings() {
            tabViewController.tabView = Tab.settings.rawValue
            sheetView.sheetVisible = false
        }
    }
}

struct KeySettingsView: View {
    @ObservedObject var viewModel: KeySettingsViewModel = KeySettingsViewModel.shared
    
    var body: some View {
        let streamingOnlySections: [SettingsSection] = [openAllSettingsSection]
        let genericSections: [SettingsSection] = [alarmSection, notificationSection, sleepSection, openAllSettingsSection]

        let sections = viewModel.dataSourceManager.dataSource.canSetKeySettings ? genericSections : streamingOnlySections
        
        Form {
            NightDimmerView(makeItSmall: false)
            MainChartLegendaView()
            ForEach(sections) { section in
                self.section(from: section)
            }
        }
        .modifier(MyRadialViewModifier(isList: true))
    }

    func section(from section: SettingsSection) -> some View {
        Section(
            header: Text(section.header ?? "")
                .modifier(FormSectionHeaderText(color: section.isEnabled ? section.foregroundColor : .gray)),
            footer: Text(section.footer ?? "")
                .lineLimit(nil)
        ) {
            ForEach(section.rows) { row in
                SettingsRowView(kind: row)
                    .foregroundColor(section.isEnabled ? section.foregroundColor : .gray)
            }
        }.disabled(!section.isEnabled)
    }
}
