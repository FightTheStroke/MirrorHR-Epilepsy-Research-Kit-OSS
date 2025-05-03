//
//  SendEmailViewController.swift
//  
//
//  Created by Roberto D’Angelo on 13/04/22.
//

import Foundation
import MessageUI
import UIKit
import SwiftUI
import SharedPkg

@available(iOS 13.0, macOS 10.15, *)
public struct SendEmailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @State private var result: Result<MFMailComposeResult, Error>?
    private var attachmentPath: String?
    private var recipients: [String]?
    private var subject: String?
    private var messageBody: String?
    private var attachmentFileName: String?
    
    public init(attachSharedMainDebuggerLog: Bool?,
                recipients: [String]?,
                subject: String?,
                messageBody: String?,
                attachmentPath: String?,
                attachmentFileName: String?,
                completion: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
        self.attachmentPath = attachmentPath
        self.attachmentFileName = attachmentFileName
        self.recipients = recipients
        self.subject = subject
        self.messageBody = messageBody
    }
    
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding public var presentation: PresentationMode
        @Binding public var result: Result<MFMailComposeResult, Error>?
        
        public init(presentation: Binding<PresentationMode>,
                    result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        public func mailComposeController(_: MFMailComposeViewController,
                                          didFinishWith result: MFMailComposeResult,
                                          error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation,
                    result: $result)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<SendEmailView>) -> MFMailComposeViewController {
        let mailViewController = MFMailComposeViewController()
        mailViewController.setToRecipients(recipients)
        mailViewController.setSubject(subject ?? "")
        mailViewController.setMessageBody(messageBody ?? "", isHTML: true)
        mailViewController.mailComposeDelegate = context.coordinator
        guard let attachmentPath = attachmentPath else {
            mainDebugger.append("Failed create logFile path URL")
            return mailViewController
        }
        
        guard let data = NSData(contentsOfFile: attachmentPath), let attachmentFileName = attachmentFileName else {
            return mailViewController
        }
        
        mailViewController.addAttachmentData(data as Data, mimeType: "application/json", fileName: attachmentFileName)
        
        return mailViewController
    }
    
    public func updateUIViewController(_: MFMailComposeViewController,
                                       context _: UIViewControllerRepresentableContext<SendEmailView>) {
        
    }
}

struct SendEmailToDocSheetView: View {
    @Binding var isShowingMailView: Bool
    let attachmentPath: String
    let lastDays: Int
    
    func lastSymptomsRecap(_ sympts: [SymptomsData], _ numSymptoms: Int) -> String {
        var output: String = "<p>Last \(numSymptoms) symptoms:</p>"
        for symptom in sympts {
            output += "<p>\(symptom.symptom?.local() ?? "") - \(symptom.startDate?.toStdString() ?? "") </p>"
        }
        return output
    }
    
    var body: some View {
        let symptomsManager = SymptomsManager.shared
        let profile = ProfileGenericSettings.shared
        let emailDoc = profile.doctorEmail
        let kidName = profile.kidName
        let kidBirth = profile.kidBirthDate
        let kidAge = profile.kidAge
        let weight = profile.kidWeight
        let epilepsyType = profile.epilepsyType.description
        let seizuresSoFar = symptomsManager.seizuresCount()
        let distanceLastPrev = symptomsManager.distanceBetweenLastAndPreviousSeizure()
        let lastSeizure = symptomsManager.lastSeizure
        let lastSeizureLenght = lastSeizure?.Lenght()
        let lastSeizureLenghtString = "\(lastSeizureLenght?.hour ?? 0)h \(lastSeizureLenght?.minute ?? 0)m \(lastSeizureLenght?.second ?? 0)s"
        let lastSeizureDate = lastSeizure?.startDate?.toStdString()
        let lastSeizureNotes = lastSeizure?.notes
        let numSymptoms: Int = 5
        let lastSymptoms = symptomsManager.lastSymptoms(numSymptoms)
        let lastSymptomsRecapString = lastSymptomsRecap(lastSymptoms, numSymptoms)
        SendEmailView(
                 attachSharedMainDebuggerLog: false,
                 recipients: [emailDoc],
                 subject: "\(kidName) had a seizure, thanks for your immediate help.",
                 messageBody: """
                 <p>\(kidName) had a seizure, thanks for your immediate help.</p>
                 <p>Here are latest data.</p>
                 <p>Name: \(kidName)</p>
                 <p>Epilepsy type: \(epilepsyType)</p>
                 <p>Date of birth: \(kidBirth)</p>
                 <p>Age: \(kidAge)</p>
                 <p>Weight: \(weight)</p>
                 <p></p>
                 <p>Seizures so far: \(seizuresSoFar)</p>
                 <p>Last seizure: \(lastSeizureDate ?? "")</p>
                 <p>Last seizure Lenght: \(lastSeizureLenghtString)</p>
                 <p>Last seizure notes: \(lastSeizureNotes ?? "")</p>
                 <p>Time between last and previous seizure: \(distanceLastPrev)</p>
                 <p></p>
                 \(lastSymptomsRecapString)
                 <p></p>
                 <p>Last \(lastDays) days data attached.</p>
                 <p></p>
                 <p>Thank you.</p>
                 <p></p>
                 """,
                 attachmentPath: attachmentPath,
                 attachmentFileName: "MirrorHR seizure export.xlsx"
        ) { _ in
            isShowingMailView = false
        }
    }
}
