//
//  HomeView.swift
//
//
//  Created by Roberto D’Angelo on 24/09/23.
//

import Foundation
import MessageUI
import MirrorHRTelemetryPackage
import RoberdanToolBox
import SharedPkg
import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject private var profile: ProfileGenericSettings = .shared
    @ObservedObject private var symptomsManager = SymptomsManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    if symptomsManager.seizuresCount() > 0 {
                        adaptiveSection(InsightsHomeView())
                    }
                    adaptiveSection(FastLogHomeView())
                    adaptiveSection(QuickNotesHomeView())
                    adaptiveSection(WeekMedicationView())
                    adaptiveSection(TherapyHomeView())
                }
                .padding(.horizontal)
            }
            .modifier(MyRadialViewModifier(isList: false))
            .gesture(
                DragGesture().onChanged({ _ in UIApplication.shared.endEditing()
                })
            )
            .navigationBarTitle(profile.kidName, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("v. " + appVersion)
                        .foregroundColor(.secondary)  // Adaptive color for light/dark mode
                        .accessibilityLabel("App version")
                        .accessibilityHint("Displays the current app version.")
                }
                ToolbarItem {
                    HelpMeView(useCustomLabelStyle: false)
                        .foregroundColor(.accentColor)
                        .accessibilityLabel("Help button")
                        .accessibilityHint("Opens help and support.")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func adaptiveSection<Content: View>(_ content: Content) -> some View
    {
        content.adaptiveOverlay(lightCornerRadius: 10, darkCornerRadius: 10)
    }
}

public struct HelpMeView: View {
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isShowingMailView: Bool = false
    private let useCustomLabelStyle: Bool
    var icon: String
    let labelTxt: String = "doYouNeedHelpString".local()
    
    public init(useCustomLabelStyle: Bool) {
        self.useCustomLabelStyle = useCustomLabelStyle
        icon = useCustomLabelStyle ? "questionmark" : "questionmark.circle"
    }
    
    public var body: some View {
        HStack {
            if useCustomLabelStyle {
                Label(labelTxt, systemImage: icon)
                    .labelStyle(
                        ColorfulIconLabelStyle(color: stefiGreen, size: 1.0))
            } else {
                Label(labelTxt, systemImage: icon)
            }
            Spacer()
        }
        .multilineTextAlignment(.leading)
        .onTapGesture {
            if MFMailComposeViewController.canSendMail() {
                self.isShowingMailView.toggle()
            } else {
                if let url = URL(string: "contactLinkDestination".local()) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(
                result: self.$result,
                attachSharedMainDebuggerLog: false,
                recipients: [supportEmail],
                subject: "I need help with MirrorHR",
                messageBody: "Please help me with:")
        }
    }
}
