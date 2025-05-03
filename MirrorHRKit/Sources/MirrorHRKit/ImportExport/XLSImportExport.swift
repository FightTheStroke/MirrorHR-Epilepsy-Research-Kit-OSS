//
//  XLSImportExport.swift
//  
//
//  Created by Roberto D'Angelo on 07/04/22.
//

import Foundation
import SwiftUI
import SharedPkg
import XlsxReaderWriter
import UniformTypeIdentifiers

public class XLSImportExport {
    private let documentPath: String?
    private var spreadSheet: BRAOfficeDocumentPackage?
    private let paths: Array = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                   FileManager.SearchPathDomainMask.userDomainMask, true) as Array
    
    private let fileName = "/\(shortAppName)_export.xlsx"
    private var fullPath: String
    var filesToShare = [Any]()
    let sharingView: UIViewController
    static private let maxRowsXWorkSheet: Int = 500
    
    public static var mirrorHRDocument: UTType {
        UTType(importedAs: "org.openxmlformats.spreadsheetml.sheet")
    }
    
    public init() {
        fullPath = paths[0] + fileName
        documentPath = Bundle.module.path(forResource: "EmptyXls", ofType: "xlsx")
        filesToShare.append(NSURL(fileURLWithPath: fullPath))
        sharingView = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        DispatchQueue.main.async {
            self.sharingView.isModalInPresentation = true
        }
    }
    
    deinit {
        // deinitializing and freeing memory
        spreadSheet = nil
    }
    
    private func saveXls() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: fullPath))
        spreadSheet?.save(as: fullPath)
    }
    
    public func getFullPath() -> String {
        return fullPath
    }
    
    /// write down on XLS the key info like name, weight, type of epilepsy etc.
    private func exportPersonalDataXLS(worksheetNumber: Int) {
        guard let spreadSheet = spreadSheet, let personalDataWorkSheet: BRAWorksheet = spreadSheet.workbook.worksheets[worksheetNumber] as? BRAWorksheet else {
            return
        }
        mainDebugger.append("exporting personal data XLS", .justALog)
        let symptomsManager = SymptomsManager.shared
        let profile = ProfileGenericSettings.shared
        let kidName = profile.kidName
        let kidBirth = profile.kidBirthDate.toStdString()
        let kidAge = profile.kidAge
        let weight = Float(profile.kidWeight)
        let weightUnit = profile.measurementsUnit.weightUnit
        let epilepsyType = profile.epilepsyType.description
        let seizuresSoFar = String(symptomsManager.seizuresCount())
        let distanceLastPrev = symptomsManager.distanceBetweenLastAndPreviousSeizure()
        let lastSeizure = symptomsManager.lastSeizure
        let lastSeizureData = lastSeizure?.startDate?.toStdString()
        let lastSeizureNotes = lastSeizure?.notes
        
        personalDataWorkSheet.cell(forCellReference: "B7", shouldCreate: true).setDateValue(Date())
        
        personalDataWorkSheet.cell(forCellReference: "B9", shouldCreate: true).setStringValue(kidName)
        personalDataWorkSheet.cell(forCellReference: "B10", shouldCreate: true).setStringValue(kidBirth)
        personalDataWorkSheet.cell(forCellReference: "B11", shouldCreate: true).setStringValue(kidAge)
        personalDataWorkSheet.cell(forCellReference: "B12", shouldCreate: true).setFloatValue(weight)
        personalDataWorkSheet.cell(forCellReference: "C12", shouldCreate: true).setStringValue(weightUnit)
        personalDataWorkSheet.cell(forCellReference: "B13", shouldCreate: true).setStringValue(epilepsyType)
        personalDataWorkSheet.cell(forCellReference: "B14", shouldCreate: true).setStringValue(seizuresSoFar)
        personalDataWorkSheet.cell(forCellReference: "B15", shouldCreate: true).setStringValue(lastSeizureData)
        personalDataWorkSheet.cell(forCellReference: "B16", shouldCreate: true).setStringValue(distanceLastPrev)
        personalDataWorkSheet.cell(forCellReference: "B17", shouldCreate: true).setStringValue(lastSeizureNotes)
        
    }
    
    private func writeSymptomsXLS(lastDays: Int? = nil, worksheetNumber: Int, anonymized: Bool) {
        guard let spreadSheet = spreadSheet, let symptomsWorksheet: BRAWorksheet = spreadSheet.workbook.worksheets[worksheetNumber] as? BRAWorksheet else {
            return
        }
        mainDebugger.append("exporting Symptoms as XLS", .justALog)
        SymptomsManager.shared.xlsSymptomsExport(worksheet: symptomsWorksheet, maxRows: XLSImportExport.maxRowsXWorkSheet, anonymized: anonymized, lastDays: lastDays)
    }
    
    private func writeSeizuresXLS(lastDays: Int? = nil, worksheetNumber: Int, anonymized: Bool) {
        guard let spreadSheet = spreadSheet, let seizuresWorkSheet: BRAWorksheet = spreadSheet.workbook.worksheets[worksheetNumber] as? BRAWorksheet else {
            return
        }
        mainDebugger.append("exporting Seizures as XLS", .justALog)
        ReadHealthData.seizuresXLSExport(worksheet: seizuresWorkSheet, maxRows: XLSImportExport.maxRowsXWorkSheet, anonymized: anonymized, lastDays: lastDays)
    }
    
    public func share() {
        keyWindow?.rootViewController?.present(sharingView, animated: true)
    }
    
    public func sendByEmail(toLine: String, subject: String) {
        let mailtoString = "mailto:\(toLine)subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let mailtoUrl = URL(string: mailtoString!)!
        if UIApplication.shared.canOpenURL(mailtoUrl) {
            UIApplication.shared.open(mailtoUrl, options: [:])
        }
    }
    
    private func writeLastSeizuresBpmXls(lastDays: Int? = nil, worksheetNumber: Int, completion: @escaping (_ done: Bool) -> Void) {
        guard let spreadSheet = spreadSheet, let seizuresBPMWorkSheet: BRAWorksheet = spreadSheet.workbook.worksheets[worksheetNumber] as? BRAWorksheet else {
            completion(false)
            return
        }
        mainDebugger.append("exporting seizures BPM as XLS", .justALog)
        
        ReadHealthData.heartRateXLSExportLast3Seizures(lastDays: lastDays,
                                                  maxRows: XLSImportExport.maxRowsXWorkSheet,
                                                  rangeMins: 300, // 5hs before and after the event
                                                  spreadsheet: spreadSheet,
                                                  templateWorksheet: seizuresBPMWorkSheet
        ) { result in
            switch result {
            case .failure(let error):
                mainDebugger.append("writeSeizuresBpmXls error: \(error.localizedDescription)", .error, sourceModule: "writeSeizuresBpmXls")
                completion(false)
            case .success(let bpm4XlsCount):
                mainDebugger.append("export xml: \(bpm4XlsCount)", .justALog, sourceModule: "writeSeizuresBpmXls")
                completion(true)
            }
        }
    }
    
    private func writeHRVXls(lastDays: Int? = nil, worksheetNumber: Int,  completion: @escaping (_ done: Bool) -> Void) {
        guard let spreadSheet = spreadSheet, let hrvWorksheet: BRAWorksheet = spreadSheet.workbook.worksheets[worksheetNumber] as? BRAWorksheet else {
            completion(false)
            return
        }
        mainDebugger.append("exporting HRV as XLS", .justALog)
        ReadHealthData.hRVExportXML(maxRows: XLSImportExport.maxRowsXWorkSheet, worksheet: hrvWorksheet, startDate: Date().daysAgo(number: lastDays != nil ? lastDays! : 30*6), endDate: Date()) { result in
            switch result {
            case .failure(let error):
                mainDebugger.append("writeHRVXls error: \(error.localizedDescription)", .error, sourceModule: "writeHRVXls")
                completion(false)
            case .success(let hrVCount):
                mainDebugger.append("success: export xml: \(hrVCount)", .justALog, sourceModule: "writeHRVXls")
                completion(true)
            }
        }
    }
    
    public func shareXlsDataForLast(days: Int, completion: @escaping (_ readyToShare: Bool) -> Void) {
        mainDebugger.append("ShareXLSDataForLast days is starting", .justALog)
        spreadSheet = BRAOfficeDocumentPackage.open(documentPath)
        if documentPath != nil, spreadSheet != nil {
            mainDebugger.append("exporting XLS file via shareXls function", .justALog)
            exportPersonalDataXLS(worksheetNumber: 0)
            writeSymptomsXLS(lastDays: days, worksheetNumber: 1, anonymized: false)
            writeSeizuresXLS(worksheetNumber: 2, anonymized: false) // it still export full seizures list
            self.saveXls()
            self.spreadSheet = nil // for reducing memory footprint
            mainDebugger.append("XLS file ready to share with latest \(days) data", .justALog)
            completion(true)
        } else {
            mainDebugger.append("ShareXLSDataForLast: error in exporting XLS", .error, sourceModule: "shareXlsDataForLast")
            completion(false)
        }
    }
    
    public func shareFullDataAsXls(anonymized: Bool = false, completion: @escaping (_ readyToShare: Bool) -> Void) {
        mainDebugger.append("shareFullDataAsXls is starting", .justALog)
        spreadSheet = BRAOfficeDocumentPackage.open(documentPath)
        if documentPath != nil, spreadSheet != nil {
            if !anonymized {
                exportPersonalDataXLS(worksheetNumber: 0)
            }
            writeSymptomsXLS(worksheetNumber: 1, anonymized: anonymized)
            writeSeizuresXLS(worksheetNumber: 2, anonymized: anonymized)
            self.saveXls()
            self.spreadSheet = nil // for reducing memory footprint
            mainDebugger.append("full XLS file ready to share", .justALog)
            completion(true)
        } else {
            mainDebugger.append("ShareXLSDataForLast: error in exporting XLS", .error, sourceModule: "shareFullDataAsXls")
            completion(false)
        }
    }
    
    public func SmartShareXLS(anonymized: Bool = false, completion: @escaping (_ readyToShare: Bool) -> Void) {
        // TODO: If too many symptoms, export in CSV to avoid memory issues with XLS. See TODO.md for more details.
        mainDebugger.append("SmartShareXLS is starting", .justALog)
        spreadSheet = BRAOfficeDocumentPackage.open(documentPath)
        if documentPath != nil, spreadSheet != nil {
            mainDebugger.append("exporting Smart XLS file", .justALog)
            spreadSheet = BRAOfficeDocumentPackage.open(documentPath)
            if !anonymized {
                exportPersonalDataXLS(worksheetNumber: 0)
            }
            writeSymptomsXLS(worksheetNumber: 1, anonymized: anonymized)
            writeSeizuresXLS(worksheetNumber: 2, anonymized: anonymized)
            writeLastSeizuresBpmXls(worksheetNumber: 3) {done in 
                self.saveXls()
                self.spreadSheet = nil // for reducing memory footprint
                mainDebugger.append("Smart XLS file ready to share", .justALog)
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        } else {
            mainDebugger.append("ShareXLSDataForLast: error in exporting XLS", .error, sourceModule: "SmartShareXLS")
            completion(false)
        }
    }
    
    public static func importXLS(xlsFile: BRAOfficeDocumentPackage, completion: @escaping (_ importedRows: Int) -> Void) {
        guard let symptomsWorksheet: BRAWorksheet = xlsFile.workbook.worksheets[1] as? BRAWorksheet else {
            completion(0)
            return
        }
        mainDebugger.append("importing Symptoms as XLS", .justALog)
        SymptomsManager.xlsSymptomsImport(worksheet: symptomsWorksheet, maxRows: maxRowsXWorkSheet) { importedRows in
            completion(importedRows)
            return
        }
    }
}

extension XLSImportExport {
    public static func newSmartShareXLS(anonymized: Bool = false, completion: @escaping (_ readyToShare: Bool, _ xlsImportExport: XLSImportExport?) -> Void) {
        // TOODO: if too many symptoms exports  in CSV to avoid memory issues with XLS
        let xlsImportExport: XLSImportExport = XLSImportExport()
        xlsImportExport.SmartShareXLS { readyToShare in
            if readyToShare {
                completion(true, xlsImportExport)
            } else {
                completion(false, nil)
            }
        }
    }
    
    public static func newSmartShareXLSByEmail(lastDays: Int, completion: @escaping (_ attachmentPath: String) -> Void) {
        let xlsImportExport: XLSImportExport = XLSImportExport()
        xlsImportExport.shareXlsDataForLast(days: lastDays) { readyToShare in
            if readyToShare {
                completion(xlsImportExport.getFullPath())
            } else {
                completion("")
            }
        }
    }
}
