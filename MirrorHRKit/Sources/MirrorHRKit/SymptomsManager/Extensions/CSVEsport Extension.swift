//
//  CSVEsport Extension.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 19/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg
import XlsxReaderWriter

extension String {
    func prepare4CSV(_ separator: String) -> String {
        let replaceSemicolon = replacingOccurrences(of: ";", with: ",")
        let removeNewLine = replaceSemicolon.replacingOccurrences(of: "\n", with: ".")
        return removeNewLine + separator
    }
}

extension SymptomsManager {
    // MARK: CSV Export

    func csvExport(completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        let fileName = "\(shortAppName)_export_\(Date().toStdString()).csv"
        guard let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName) else {
            completion(.failure(CsvErrors.pathNotFound))
            return
        }
        
        let newLine = "\n"
        let separator = ";"
        var csvText = "Symptom;Start;End;Length;Notes;MetaData" + newLine

        for sample in symptomsData {
            guard let startDate = sample.startDate,
                  let endDate = sample.endDate,
                  let symptom = sample.symptom else {
                continue
            }
            
            let length = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: startDate, to: endDate)
            let myMetaData = sample.jsonMetaData
            csvText += NSLocalizedString(symptom, comment: "").prepare4CSV(separator)
            csvText += startDate.toStdString().prepare4CSV(separator)
            csvText += endDate.toStdString().prepare4CSV(separator)
            csvText += "\(length.hour ?? 0)h \(length.minute ?? 0)m \(length.second ?? 0)s".prepare4CSV(separator)
            csvText += (sample.notes?.replacingOccurrences(of: ";", with: ",") ?? "").prepare4CSV(separator)
            csvText += (myMetaData?.replacingOccurrences(of: ";", with: ",") ?? "").prepare4CSV(separator)
            csvText += newLine
        }

        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            mainDebugger.append("Failed to create CSV file: \(error)", .error, sourceModule: "csvExport")
            completion(.failure(error))
            return
        }
        
        mainDebugger.append("CoreData csv exported to \(path.absoluteString)")
        var filesToShare = [Any]()
        filesToShare.append(path)
        let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        DispatchQueue.main.async {
            av.isModalInPresentation = true
            if let presentedVC = keyWindow?.rootViewController?.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    keyWindow?.rootViewController?.present(av, animated: true)
                }
            } else {
                keyWindow?.rootViewController?.present(av, animated: true)
            }
        }
        completion(.success(true))
    }

    func xlsSymptomsExport(worksheet: BRAWorksheet, maxRows: Int, anonymized: Bool, lastDays: Int?) {
        // Writing the worksheet
        var exportingSymptoms: [SymptomsData]
        if let lastDays = lastDays {
            exportingSymptoms = symptomsDataForLastDays(lastDays)
        } else {
            exportingSymptoms = symptomsData
        }
        var row: Int = 1
        
        for symptom in exportingSymptoms {
            if row > maxRows {
                break
            }
            row += 1
            guard let symptomString = symptom.symptom?.local(),
                  let startDate = symptom.startDate,
                  let endDate = symptom.endDate,
                  let notes = (symptom.notes != nil) ? symptom.notes : " "
            else {
                continue
            }
            
            #if DEBUG
                logger.log(level: .info, "exporting xls symptom row: \(row)")
            #endif
            
            let Lenght = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: startDate, to: endDate)
            worksheet.cell(forCellReference: "A\(row)", shouldCreate: true).setStringValue(symptomString)
            worksheet.cell(forCellReference: "B\(row)", shouldCreate: true).setStringValue(startDate.toStdString())
            worksheet.cell(forCellReference: "C\(row)", shouldCreate: true).setStringValue(endDate.toStdString())
            worksheet.cell(forCellReference: "D\(row)", shouldCreate: true).setStringValue("\(Lenght.hour!)h \(Lenght.minute!)m \(Lenght.second!)s")
            if !anonymized {
                worksheet.cell(forCellReference: "E\(row)", shouldCreate: true).setStringValue(notes)
            }
        }
    }
    
    static func xlsSymptomsImport(worksheet: BRAWorksheet, maxRows: Int, completion: @escaping (_ importedRows: Int) -> Void) {
        // Reading the worksheet
        let initialRow: Int = 2
        let worksheetRows = worksheet.rows.count <= maxRows ? worksheet.rows.count : maxRows
        var importedRows: Int = 0
        for currentRow in initialRow...(worksheetRows + 1) {
            guard let symptCell = worksheet.cell(forCellReference: "A\(currentRow)"),
                    let startDateCell = worksheet.cell(forCellReference: "B\(currentRow)"),
                    let endDateCell = worksheet.cell(forCellReference: "C\(currentRow)"),
                    let notesCell = worksheet.cell(forCellReference: "E\(currentRow)")
            else {
                continue
            }
            let symptString = symptCell.stringValue()
            let symptEvent: HandledSymptomsEvents = reverseLocalizationSymtp(symptString ?? "")
            let startDateString = startDateCell.stringValue()
            let endDateString = endDateCell.stringValue()
            let startDate = Date.fromStdDateString(startDateString ?? "")
            let endDate = Date.fromStdDateString(endDateString ?? "")
            let notes = notesCell.stringValue()
            
//            mainDebugger.append("TEST IMPORT row \(currentRow): \(String(describing: symptString)) \(String(describing: startDate)) \(String(describing: endDate)) \(notes)", .justALog)
            let symptomLog = SymptomLog(symptEvent, startDate: startDate, endDate: endDate, severity: .mild, jsonMetaData: nil, notes: notes)
            shared.appendSymptomLog(symptomLog)
            importedRows += 1
        }
        completion(importedRows)
    }
    
    enum XLSErrors: Error {
        case emptyLine
    }
    
    enum CsvErrors: Error {
        case pathNotFound

        var localizedDescription: String {
            switch self {
            case .pathNotFound:
                return "The specified path was not found."
            }
        }
    }
}
