//
//  BackupAndRestoreView.swift
//
//
//  Created by Roberto D’Angelo on 14/06/24.
//

import SwiftUI
import UniformTypeIdentifiers
import SharedPkg
import MirrorHRTelemetryPackage

struct BackupView: View {
    @State private var showDocumentPicker = false
    @State private var backupURL: URL?
    @State private var thereIsAnError: String?
    @State private var restoreDone: Bool = false
    @State private var isProcessing: Bool = false
    @State private var showRestoreConfirmation: Bool = false
    @State private var selectedRestoreURL: URL?
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                ActionButton(title: "CreateMirrorHRBckTitle".local(), action: createBackup)
                    .padding()
                    .disabled(isProcessing)
                if let backupURL = backupURL {
                    ShareLink("", item: backupURL)
                        .foregroundColor(stefiGreen)
                }
            }
            
            if restoreDone {
                ActionButton(title: "BackupRestoredMsg".local()) {}
                    .disabled(true)
                    .foregroundColor(stefiGreen)
                    .padding()
            } else {
                ActionButton(title: "RestoreBackupMsg".local()) {
                    showDocumentPicker = true
                }
                .padding()
                .disabled(isProcessing)
            }
            
            if let thereIsAnError = thereIsAnError {
                Divider()
                Text(thereIsAnError)
                    .foregroundColor(stefiRed)
            }
            
            if isProcessing {
                ProgressView("ProcessingMsg".local())
                    .padding()
            }
            
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                if let url = url {
                    self.selectedRestoreURL = url
                    self.showRestoreConfirmation = true
                }
            }
        }
        .alert(isPresented: $showRestoreConfirmation) {
            Alert(
                title: Text("ConfirmRestoreMsg".local()),
                message: Text("ConfirmRestoreMessageExt".local()),
                primaryButton: .destructive(Text("RestoreOnlyMsg".local())) {
                    if let url = selectedRestoreURL {
                        startRestoreBackup(from: url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func createBackup() {
        isProcessing = true
        thereIsAnError = nil
        backupURL = nil
        
        BackupManager.createBackup { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success(let url):
                    mainDebugger.append("Backup created at: \(url.path)", .justALog)
                    backupURL = url
                case .failure(let error):
                    mainDebugger.append("Backup failed: \(error.localizedDescription)", .error)
                    thereIsAnError = "I can't create the backup :-("
                }
            }
        }
    }
    
    private func startRestoreBackup(from url: URL) {
        // IMPORTANT: it resets everything before restoring from backup
        sendEraseLocalStoragesCommandToAllStorages()
        sendResetToDefaultValuesToEverySubscriber()
        sendResetEraseToEverySubscriber()
        isProcessing = true
        thereIsAnError = nil
        restoreDone = false
        
        restoreBackup(from: url) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success:
                    print("RestoreCompleteSuccessMsg".local())
                    restoreDone = true
                case .failure(let error):
                    print("\("RestoreFailureMsg".local()) \(error.localizedDescription)")
                    thereIsAnError = "BackupErrorSorryMsg".local()
                }
            }
        }
    }
    
    private func restoreBackup(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        BackupManager.restoreBackup(from: url) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var didPickDocuments: ((URL?) -> Void)
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didPickDocuments: didPickDocuments)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var didPickDocuments: ((URL?) -> Void)
        
        init(didPickDocuments: @escaping (URL?) -> Void) {
            self.didPickDocuments = didPickDocuments
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            didPickDocuments(urls.first)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            didPickDocuments(nil)
        }
    }
}
