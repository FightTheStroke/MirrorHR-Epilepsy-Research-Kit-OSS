//
//  ImportExportViewModel.swift
//
//  Created by Roberto D'Angelo on 20/07/22.
//

import Foundation
import SwiftUI
import MessageUI
import SharedPkg
import UniformTypeIdentifiers

public struct MyAlert {
    var title: String
    var message: AnyView
    var actions: AnyView
    
    let defaultTitle = "warningMsg".local()
    let defaultMessage = AnyView(Text("waitExportFileMsg".local()))
    let defaultActions = AnyView(EmptyView())
    
    public init() {
        title = defaultTitle
        message = defaultMessage
        actions = defaultActions
    }
    
    public mutating func set2Default() {
        title = defaultTitle
        message = defaultMessage
        actions = defaultActions
    }
}

// TODO: Test import and export functions for reliability and edge cases. See TODO.md and ROADMAP.md for more details.

/// ImportExportViewModel manages the import and export functionality for symptoms data.
/// 2024 Refactoring improvements:
/// - Thread safety with @MainActor
/// - State management with isHandlingStatus flag
/// - Error handling with dedicated methods
/// - Optimized UI updates
/// - Organized code structure
@MainActor
final public class ImportExportViewModel: ObservableObject {
    public static let shared: ImportExportViewModel = ImportExportViewModel()
    public let howManyLastDays: Int = 10
    public var attachmentPath: String = ""
    private let symptomsManager: SymptomsManager = .shared
    private let blockingActionInProgressModel: BlockingActionInProgressModel = .shared
    private var csvContent: String?
    
    @Published var isShowingAlert: Bool = false
    @Published var isShowingMailView: Bool = false {
        didSet {if oldValue == true && !isShowingMailView { self.status = .exportCompleted }}
    }
    @Published var isFileImporterShowing: Bool = false {
        didSet {
            if !isFileImporterShowing {
                status = .isNotActive
            }
        }
    }
    
    /// Flag to prevent re-entrancy in state changes
    private var isHandlingStatus = false
    
    /// Current state of import/export operations
    /// - Note: Using internal(set) allows writes within the same module
    @Published var status: ImportExportStatus = .isNotActive {
        didSet {
            guard !isHandlingStatus && oldValue != status else { return }
            mainDebugger.append("ImportExportViewModel status is: \(status)")
            handleStatusChange()
        }
    }
    
    @Published var myAlert: MyAlert = MyAlert()
    
    /// Manages state transitions and UI updates
    /// - Note: Protected against re-entrancy with isHandlingStatus flag
    private func handleStatusChange() {
        isHandlingStatus = true
        defer { isHandlingStatus = false }
        
        switch status {
        case .isShowingFileImporter:
            isFileImporterShowing = true

        case .isChoosingHowToImport:
            setupImportAlert()
            
        case .isImportingAppending:
            guard let csvContent = csvContent else {
                setError("No content available for import")
                return
            }
            handleImportAppending(csvContent)
            
        case .isImportingOverwriting:
            guard let csvContent = csvContent else {
                setError("No content available for import")
                return
            }
            handleImportOverwriting(csvContent)
            
        case .isExporting:
            setupExportState()

        case .importCompleted(let importedRows):
            setupImportCompletedState(rows: importedRows)

        case .exportCompleted:
            status = .isNotActive
            
        case .isNotActive:
            resetUIState()

        case .error(let description):
            setupErrorState(description: description)
            
        case .sendingEmail:
            setupEmailState()
        }
    }
    
    /// Handles append import operation
    /// - Parameter csvContent: CSV content to import
    private func handleImportAppending(_ csvContent: String) {
        blockingActionInProgressModel.blockingActionIsInProgress = true
        Task {
            let importedRows = await symptomsManager.importCSV(csvContent)
            status = .importCompleted(rows: importedRows)
        }
    }
    
    /// Handles overwrite import operation
    /// - Parameter csvContent: CSV content to import
    private func handleImportOverwriting(_ csvContent: String) {
        blockingActionInProgressModel.blockingActionIsInProgress = true
        symptomsManager.clearAllItems { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                Task {
                    let importedRows = await self.symptomsManager.importCSV(csvContent)
                    self.status = .importCompleted(rows: importedRows)
                }
            case .failure(let error):
                status = .error(description: error.localizedDescription)
            }
        }
    }
    
    /// Sets up import alert UI
    private func setupImportAlert() {
        myAlert.title = "warningMsg".local()
        myAlert.message = AnyView(EmptyView())
        myAlert.actions = AnyView(OverWriteCheckView())
        isShowingAlert = true
    }
    
    /// Sets up export state UI
    private func setupExportState() {
        resetUIState()
        myAlert.message = AnyView(Text("waitExportFileMsg".local()))
    }
    
    /// Sets up import completion UI
    /// - Parameter rows: Number of imported rows
    private func setupImportCompletedState(rows: Int) {
        blockingActionInProgressModel.blockingActionIsInProgress = false
        isFileImporterShowing = false
        myAlert.title = "ImportCompleteLocalizedAlertTitle".local()
        myAlert.message = AnyView(Text("ImportedNElementsFromXLSLocalized".local() + " \(rows)"))
        myAlert.actions = AnyView(confirmImportAction)
        isShowingAlert = true
    }
    
    /// Sets up error state UI
    /// - Parameter description: Error message
    private func setupErrorState(description: String) {
        resetUIState()
        isShowingAlert = true
        myAlert.title = "errorMsg".local()
        myAlert.message = AnyView(Text(description))
    }
    
    /// Sets up email state UI with delay
    private func setupEmailState() {
        resetUIState()
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isShowingMailView = true
        }
    }
    
    /// Sets error state
    /// - Parameter description: Error message
    private func setError(_ description: String) {
        status = .error(description: description)
    }
    
    /// Resets all UI elements to default state
    private func resetUIState() {
        blockingActionInProgressModel.blockingActionIsInProgress = false
        isFileImporterShowing = false
        myAlert.set2Default()
        isShowingAlert = false
        isShowingMailView = false
    }
    
    private init() {
        
    }
    
    public enum ImportExportStatus: Equatable {
        case isShowingFileImporter
        case isChoosingHowToImport
        case isImportingOverwriting
        case isImportingAppending
        case isExporting
        case importCompleted(rows: Int)
        case sendingEmail
        case exportCompleted
        case isNotActive
        case error(description: String)
    }
    
    public var menuView: some View {
        VStack {
            Button("exportAndShareDataXLS".local()) {
                DispatchQueue.main.async {
                    self.status = .isExporting
                    XLSImportExport.newSmartShareXLS { readyToShare, xlsImportExport in
                        if readyToShare && xlsImportExport != nil {
                            self.status = .exportCompleted
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                xlsImportExport?.share()
                            }
                        } else {
                            self.status = .error(description: "I'm sorry, can't export data.".local())
                        }
                    }
                }
            }
            
            Button("shareWithDoctorTask".local()) {
                DispatchQueue.main.async {
                    self.status = .isExporting
                    let xlsImportExport: XLSImportExport = XLSImportExport()
                    xlsImportExport.shareXlsDataForLast(days: self.howManyLastDays) { readyToShare in
                        if readyToShare {
                            self.attachmentPath = xlsImportExport.getFullPath()
                            self.status = .sendingEmail
                        } else {
                            self.status = .exportCompleted
                        }
                    }
                }
            }
            .disabled(!MFMailComposeViewController.canSendMail())
            Button("backupSymptomsDataString".local()) {
                self.backupBtnAction()
            }
            
            Button("restoreSymptomsDataString".local()) {
                self.status = .isShowingFileImporter
            }
        }
    }
    
    func backupBtnAction() {
        let symptomsManager = SymptomsManager.shared
        DispatchQueue.main.async {
            self.status = .isExporting
        }
        symptomsManager.csvExport { _ in
            DispatchQueue.main.async {
                self.status = .exportCompleted
            }
        }
    }
    
    public var confirmImportAction: some View {
        VStack {
            Button("okActionMsg".local()) {
                self.status = .isNotActive
            }
        }
    }

    func restoreSymptoms(_ csvContent: String) {
        self.csvContent = csvContent
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            status = .isChoosingHowToImport
        }
    }
    
    public var menuViewHome: some View {
        VStack {
            Button("exportAndShareDataXLS".local()) {
                DispatchQueue.main.async {
                    self.status = .isExporting
                    XLSImportExport.newSmartShareXLS { readyToShare, xlsImportExport in
                        if readyToShare && xlsImportExport != nil {
                            self.status = .exportCompleted
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                xlsImportExport?.share()
                            }
                        } else {
                            self.status = .error(description: "I'm sorry, can't export data.".local())
                        }
                    }
                }
            }
            
            Button("shareWithDoctorTask".local()) {
                DispatchQueue.main.async {
                    self.status = .isExporting
                    let xlsImportExport: XLSImportExport = XLSImportExport()
                    xlsImportExport.shareXlsDataForLast(days: self.howManyLastDays) { readyToShare in
                        if readyToShare {
                            self.attachmentPath = xlsImportExport.getFullPath()
                            self.status = .sendingEmail
                        } else {
                            self.status = .exportCompleted
                        }
                    }
                }
            }
            .disabled(!MFMailComposeViewController.canSendMail())
        }
    }
}

public struct OverWriteCheckView: View {
    @ObservedObject var importExportViewModel: ImportExportViewModel = .shared
    private var symptomsManager = SymptomsManager.shared
    
    public var body: some View {
        VStack {
            Button("BtnOverwriteMsg".local(), role: .destructive) {
                DispatchQueue.main.async { [self] in
                    importExportViewModel.status = .isImportingOverwriting
                }
            }
            
            Button("BtnAppendMsg".local()) {
                DispatchQueue.main.async { [self] in
                    importExportViewModel.status = .isImportingAppending
                }
            }
            
            Button("BtnCancelMsg".local(), role: .cancel) {
                DispatchQueue.main.async { [self] in
                    importExportViewModel.status = .isNotActive
                }
            }
        }
    }
}
