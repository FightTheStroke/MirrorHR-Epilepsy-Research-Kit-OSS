//
//  DebugLogsView.swift
//  it shows a view with all the logs from MainDebugger.shared
//  and it enables to send an email with the logs attached
//  Created by Roberto D’Angelo on 22/12/20.
//

#if os(iOS)
    import Foundation
    import MessageUI
    import SwiftUI

    public struct DebugLogsView: View {
        @ObservedObject var myDebugger = MainDebugger.shared
        @State private var result: Result<MFMailComposeResult, Error>?
        @State private var isShowingMailView: Bool = false

        public init() {}

        public var body: some View {
            VStack {
                HStack {
                    Button("Share debug log", action: {
                        self.isShowingMailView.toggle()
                    })
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(result: self.$result,
                                 attachSharedMainDebuggerLog: true,
                                 recipients: ["info@fightthestroke.org"],
                                 subject: "MirrorHR Feedback",
                                 messageBody: "<p>Feedback on MirrorHR</p>")
                    }
                }
                DebuggerLogsView()
            }
        }
    }

    public struct DebuggerLogsView: View {
        @ObservedObject var myDebugger = MainDebugger.shared

        public var body: some View {
            Picker(selection: $myDebugger.typeFilter, label: Text("")) {
                ForEach(DebugMsgType.allCases, id: \.self) {
                    Text($0.description)
                }
            }

            List(myDebugger.debugLogs.filter { myDebugger.typeFilter.contains($0.msgType) }, id: \.self) { logs in
                LogsRow(logs: logs)
            }
        }
    }

    public struct DebugLogsView_Previews: PreviewProvider {
        public static var previews: some View {
            DebugLogsView()
        }
    }

#endif
