//
//  ShareAFeedbackView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import MessageUI
import RoberdanToolBox
import SwiftUI
import SharedPkg

public struct ShareAFeedbackLocalizedView: View {
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isShowingMailView: Bool = false

    public init() {}

    public var body: some View {
        VStack {
            HStack {
                Button(shareFeedbackString, action: {
                    self.isShowingMailView.toggle()
                })
                .disabled(!MFMailComposeViewController.canSendMail())
                .sheet(isPresented: $isShowingMailView) {
                    MailView(result: self.$result,
                             attachSharedMainDebuggerLog: false,
                             recipients: [suggestionsEmail],
                             subject: "MirrorHR Suggestions & Feedbacks",
                             messageBody: "<p>Feedback on MirrorHR</p>")
                }
            }
        }
        .multilineTextAlignment(.center)
    }
}

public struct INeedHelpView: View {
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isShowingMailView: Bool = false
    let doYouNeedHelpString = NSLocalizedString("doYouNeedHelpString", comment: "")

    public init() {}

    public var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isShowingMailView.toggle()
                }, label: {
                    Label("doYouNeedHelpString".local(), systemImage: "questionmark")
                        .labelStyle(.iconOnly)
                })
                .disabled(!MFMailComposeViewController.canSendMail())
                .sheet(isPresented: $isShowingMailView) {
                    MailView(result: self.$result,
                             attachSharedMainDebuggerLog: false,
                             recipients: [supportEmail],
                             subject: "I need help with MirrorHR",
                             messageBody: "Please help me with:")
                }
            }
        }
        .multilineTextAlignment(.center)
    }
}
