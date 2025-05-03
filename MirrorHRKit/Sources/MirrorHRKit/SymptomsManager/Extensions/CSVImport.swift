//
//  CSVImport.swift
//  
//
//  Created by Roberto D’Angelo on 01/02/22.
//

import Foundation
import SwiftUI
import SharedPkg
import UniformTypeIdentifiers
import XlsxReaderWriter
import OSLog

extension SymptomsManager {
    public struct ImportView: View {
        @State private var isImporting: Bool = false
        @State private var importedRows: Int = -1
        @State private var resultMsg: String = ""
        @State private var showingAlert: Bool = false
        @State private var confirmOverwrite: Bool = false
        let logger = Logger(subsystem: "SymptomsManager", category: "ImportView")
        
        public var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button("ImportMirrorHRXLSLocalized".local()) { confirmOverwrite = true }
                        .disabled(isImporting)
                        .alert("AlertConfirmMsgText".local(), isPresented: $confirmOverwrite) {
                            Button(role: .destructive, action: {
                                isImporting = false
                                // fix broken picker sheet
                                shared.clearAllItems { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isImporting = true
                                    }
                                }
                            }, label: {
                                Text("BtnOverwriteMsg".local())
                            })
                            
                            Button("BtnAppendMsg".local()) {
                                isImporting = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isImporting = true
                                }
                            }
                            
                            Button(role: .cancel, action: {
                                isImporting = false
                            }, label: {
                                Text("BtnCancelMsg")
                            })
                        }
                    
                    Divider()
                    SymptomsManager.CsvImportView()
                    Spacer()
                        .fileImporter(
                            isPresented: $isImporting,
                            allowedContentTypes: [XLSImportExport.mirrorHRDocument],
                            allowsMultipleSelection: false
                        ) { result in
                            do {
                                guard let selectedFile: URL = try result.get().first else { return }
                                // trying to get access to url contents
                                if CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL) {
                                    guard let xlsFile =  BRAOfficeDocumentPackage.open(selectedFile.path)
                                    else {
                                        mainDebugger.append("Imported File is not an xlsx file", .error, sourceModule: "SymptomsManager ImportView")
                                        return
                                    }
                                    
                                    XLSImportExport.importXLS(xlsFile: xlsFile) { importedRows in
                                        self.importedRows = importedRows
                                        isImporting = false
                                        if self.importedRows >= 1 {
                                            let importedRowsMsg = self.importedRows > 0 ? " \(self.importedRows)" : ""
                                            resultMsg = "ImportedNElementsFromXLSLocalized".local() + importedRowsMsg
                                            showingAlert = true
                                        }
                                    }
                                    // done accessing the url
                                    CFURLStopAccessingSecurityScopedResource(selectedFile as CFURL)
                                } else {
                                    logger.error("Permission error!")
                                    resultMsg = "CanTReadTheXLSFileLocalized".local()
                                }
                            } catch {
                                // Handle failure.
                                logger.error("\(error.localizedDescription)")
                                resultMsg = error.localizedDescription
                            }
                        }
                        .alert("ImportCompleteLocalizedAlertTitle".local(), isPresented: $showingAlert, actions: {
                            Button(role: .cancel, action: {
                                DispatchQueue.main.async {
                                    self.showingAlert = false
                                }
                            }, label: {
                                Text(resultMsg)
                            })
                        }, message: {
                            Text("waitExportFileMsg".local())
                        })
                }
            }
            .if(isImporting) { $0.overlay(ProgressView()) }
        }
    }
}

extension SymptomsManager {
    public static func reverseLocalizationSymtp(_ string: String) -> HandledSymptomsEvents {
        var returnSympt: HandledSymptomsEvents = .other
        HandledSymptomsEvents.allCases.forEach { sympt in
            if sympt.localizedString() == string {
                returnSympt = sympt
            }
        }
        return returnSympt
    }
}

extension SymptomsManager {
    public struct CsvImportView: View {
        @State private var isImporting: Bool = false
        @State private var importedRows: Int = -1
        @State private var errorMsg: String?
        @State private var showingAlert: Bool = false
        private let symptomsManager: SymptomsManager = .shared
        let logger = Logger(subsystem: "SymptomsManager", category: "CsvImportView")
        
        public var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isImporting = false
                        // fix broken picker sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isImporting = true
                        }
                    }, label: {
                        Text("ImportMirrorHRCSVLocalized".local())
                    })
                    .disabled(isImporting)
                    Spacer()
                        .fileImporter(
                            isPresented: $isImporting,
                            allowedContentTypes: [UTType.plainText],
                            allowsMultipleSelection: false
                        ) { result in
                            do {
                                guard let selectedFile: URL = try result.get().first else { return }
                                // trying to get access to url contents
                                if CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL) {
                                    guard let csvContent = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                                    // done accessing the url
                                    CFURLStopAccessingSecurityScopedResource(selectedFile as CFURL)
                                    Task {
                                        do {
                                            self.importedRows = await symptomsManager.importCSV(csvContent)
                                            isImporting = false
                                            if self.importedRows >= 1 {
                                                showingAlert = true
                                            }
                                        }
                                     }
                                } else {
                                    errorMsg = "CanTReadTheCSVFileLocalized".local()
                                    logger.error("Permission error: can't read the CSV file")
                                }
                            } catch {
                                // Handle failure.
                                errorMsg = error.localizedDescription
                                logger.error("\(error.localizedDescription)")
                            }
                        }
                        .alert("ImportCompleteLocalizedAlertTitle".local(), isPresented: $showingAlert, actions: {
                            Button(role: .cancel, action: {
                                DispatchQueue.main.async {
                                    self.showingAlert = false
                                }
                            }, label: {
                                Text(gotItMsg)
                            })
                        }, message: {
                            Text("ImportedNElementsFromXLSLocalized".local() +
                                 " \(self.importedRows)")
                        })
                    if isImporting {
                        ProgressView()
                    }
                }
            }
        }
    }
    
    public func importCSV(_ csvContent: String) async -> Int {
        var parsedCSV: [String] = csvContent.components(separatedBy: "\n")
        parsedCSV.removeFirst() // removing the header "Symptom;Start;End;Lenght;Notes;MetaData"
        parsedCSV.removeLast() // removing last line that is just a \n
        parsedCSV.forEach { line in
            let elements = line.components(separatedBy: ";")
            if elements.count == 7 {
                let symptString: String = elements[0]
                let symptEvent: HandledSymptomsEvents = SymptomsManager.reverseLocalizationSymtp(symptString)
                let startDate = Date.fromStdDateString(elements[1])
                let endDate = Date.fromStdDateString(elements[2])
                // let Lenght = elements[3]
                let notes = elements[4]
                let metaData = elements[5]
                let symptomLog = SymptomLog(symptEvent, startDate: startDate, endDate: endDate, severity: .mild, jsonMetaData: metaData, notes: notes)
                appendSymptomLog(symptomLog, isBulkInsert: true)
                mainDebugger.append("importing from CSV symptom: \(symptomLog.symptom)")
            }
        }
        fetch()
        return parsedCSV.count
    }
}
