//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 05/02/22.
//

import Foundation
import HealthKit
import SwiftUI
import SharedPkg
import XlsxReaderWriter

extension ReadHealthData {
    public static func heartRateCSVExport(startDate: Date, endDate: Date, completion: @escaping (Result<Int, Error>, _ isShareSheetShowing: Bool) -> Void) {
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let heartRateUnit = HKUnit(from: "count/min")
        
        let fileName = "\(shortAppName)_HeartRate_Export\(Date().toStdString()).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let newLine = "\n"
        let separator = ";"
        var csvText = "Day;Time;BPM (count/min)" + newLine
        
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                           predicate: predicate, limit: HKObjectQueryNoLimit,
                                           sortDescriptors: sortDescriptors) { _, results, _ in
            guard let samples = results as? [HKQuantitySample] else {
                mainDebugger.append(Errors.noData.debugDescription, .error, sourceModule: "heartRateCSVExport")
                completion(.failure(Errors.noData.error), false)
                return
            }
            DispatchQueue.main.async {
                for sample in samples {
                    let date: Date = sample.startDate
                    let bpm: Double = sample.quantity.doubleValue(for: heartRateUnit)
                    csvText += date.toDayMonthYear().prepare4CSV(separator)
                    csvText += date.toPreciseTime().prepare4CSV(separator)
                    csvText += "\(Int(bpm))".prepare4CSV(separator)
                    csvText += newLine
                }
                
                do {
                    try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    mainDebugger.append("Failed to create CSV file: \(error)", .error, sourceModule: "heartRateCSVExport")
                    completion(.failure(error), false)
                }
                mainDebugger.append("BPM csv exported to \(path?.absoluteString ?? "csv path not found")")
                var filesToShare = [Any]()
                filesToShare.append(path!)
                let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                av.isModalInPresentation = true
                keyWindow?.rootViewController?.present(av, animated: true)
                completion(.success(samples.count), false)
            }
        }
        healthStore.execute(heartRateQuery)
    }
    
    public static func heartRateCSVExportSeizures(completion: @escaping (Result<Int, Error>, _ isShareSheetShowing: Bool) -> Void) {
        DispatchQueue.global(qos: .default).async { [self] in
            let fileName = "\(shortAppName)_HeartRateSeizuresCSV_Export\(Date().toStdString()).csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            let newLine = "\n"
            let separator = ";"
            var csvText = ""
            let csvBPMText = "Day;Time;BPM (count/min)" + newLine
            let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            let heartRateUnit = HKUnit(from: "count/min")
            
            let seizuresOnly = SymptomsManager.shared.symptomsData
                .filter { sympt in
                    SymptomsManager.shared.seizuresLogOnlySymptomsArray.contains(HandledSymptomsEvents(rawValue: sympt.symptom!) ?? .none)
                }
            if seizuresOnly.isEmpty {
                return
            }
            
            seizuresOnly.forEach { seizure in
                let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: seizure.startDate?.daysAgo(number: 3),
                                                                          end: seizure.endDate?.addDay(number: 3),
                                                                          options: HKQueryOptions.strictStartDate)
                let heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                                   predicate: predicate, limit: HKObjectQueryNoLimit,
                                                   sortDescriptors: sortDescriptors) { _, results, _ in
                    guard let samples = results as? [HKQuantitySample] else {
                        mainDebugger.append(Errors.noData.debugDescription, .error, sourceModule: "heartRateCSVExportSeizures")
                        completion(.failure(Errors.noData.error), false)
                        return
                    }
                    DispatchQueue.main.async {
                        csvText = seizuresCSV(seizures: seizuresOnly) + newLine + csvBPMText
                        
                        for sample in samples {
                            let date: Date = sample.startDate
                            let bpm: Double = sample.quantity.doubleValue(for: heartRateUnit)
                            csvText += date.toDayMonthYear().prepare4CSV(separator)
                            csvText += date.toPreciseTime().prepare4CSV(separator)
                            csvText += "\(Int(bpm))".prepare4CSV(separator)
                            csvText += newLine
                        }
                        
                        do {
                            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                        } catch {
                            mainDebugger.append("Failed to create CSV file: \(error)", .error, sourceModule: "heartRateCSVExportSeizures")
                            completion(.failure(error), false)
                        }
                        mainDebugger.append("BPM csv exported to \(path?.absoluteString ?? "csv path not found")")
                        var filesToShare = [Any]()
                        filesToShare.append(path!)
                        let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                        av.isModalInPresentation = true
                        keyWindow?.rootViewController?.present(av, animated: true)
                        completion(.success(samples.count), false)
                    }
                }
                healthStore.execute(heartRateQuery)
            }
        }
    }
    
    public static func seizuresCSV(seizures: [SymptomsData]) -> String {
        let newLine = "\n"
        let separator = ";"
        var csvText = "Symptom;Start;End;Lenght;Notes;MetaData" + newLine
        
        seizures.forEach { sample in
            let Lenght = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: sample.startDate!, to: sample.endDate!)
            let myMetaData = sample.jsonMetaData
            
            csvText += NSLocalizedString(sample.symptom!, comment: "").prepare4CSV(separator)
            csvText += sample.startDate!.toStdString().prepare4CSV(separator)
            csvText += sample.endDate!.toStdString().prepare4CSV(separator)
            csvText += "\(Lenght.hour!)h \(Lenght.minute!)m \(Lenght.second!)s".prepare4CSV(separator)
            csvText += (sample.notes?.replacingOccurrences(of: ";", with: ",") ?? "").prepare4CSV(separator)
            csvText += (myMetaData?.replacingOccurrences(of: ";", with: ",") ?? "").prepare4CSV(separator)
            csvText += newLine
        }
        return csvText
    }
    
    public static func seizuresXLSExport(worksheet: BRAWorksheet, maxRows: Int, anonymized: Bool, lastDays: Int? = nil) {
        let seizuresOnly = SymptomsManager.shared.seizuresForLastDays(lastDays)
        
        if seizuresOnly.isEmpty {
            return
        }
        
        var row: Int = 1
        let dateFormat: String = "dd/mm/yyyy hh:mm:ss"
        var sincePreviousSeizure: String = ""

        for (index, seizure) in seizuresOnly.enumerated() {
            if row > maxRows {
                break
            }
            row += 1
            sincePreviousSeizure = ""

            if index < seizuresOnly.count - 1 {
                let previousSeizure = seizuresOnly[index + 1]
                let sincePrevSeizureDate = Calendar.current.dateComponents(
                    [.day, .hour, .minute],
                    from: previousSeizure.endDate ?? Date(),
                    to: seizure.startDate ?? Date()
                )
                sincePreviousSeizure = "\(sincePrevSeizureDate.day!)d \(sincePrevSeizureDate.hour!)h \(sincePrevSeizureDate.minute!)m"
            }
            let Lenght = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: seizure.startDate!, to: seizure.endDate!)
            worksheet.cell(forCellReference: "A\(row)", shouldCreate: true).setStringValue(seizure.symptom?.local())
            worksheet.cell(forCellReference: "B\(row)", shouldCreate: true).setDateValue(seizure.startDate!)
            worksheet.cell(forCellReference: "B\(row)").setNumberFormat(dateFormat)
            worksheet.cell(forCellReference: "C\(row)", shouldCreate: true).setDateValue(seizure.endDate!)
            worksheet.cell(forCellReference: "C\(row)").setNumberFormat(dateFormat)
            worksheet.cell(forCellReference: "D\(row)", shouldCreate: true).setStringValue("\(Lenght.hour!)h \(Lenght.minute!)m \(Lenght.second!)s")
            worksheet.cell(forCellReference: "E\(row)", shouldCreate: true).setStringValue(sincePreviousSeizure)
            if !anonymized {
                worksheet.cell(forCellReference: "F\(row)", shouldCreate: true).setStringValue(seizure.notes)
            }
        }
    }
    
    public static func heartRateXLSExportLast3Seizures(lastDays: Int? = nil, maxRows: Int, rangeMins: Int, spreadsheet: BRAOfficeDocumentPackage, templateWorksheet: BRAWorksheet, completion: @escaping (Result<Int, Error>) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let heartRateUnit = HKUnit(from: "count/min")
        
        let seizuresOnly = SymptomsManager.shared.seizuresForLastDays(lastDays)
            .prefix(3) // max 3 seizures to avoid issues with excel
        
        if seizuresOnly.isEmpty {
            completion(.failure(Errors.noData.error))
            return
        }
        
        mainDebugger.append("exporting \(seizuresOnly.count) seizures. First Date: \(seizuresOnly.first?.startDate?.toStdString() ?? "none") and End Date: \(seizuresOnly.last?.startDate?.toStdString() ?? "none")", .justALog)
        
        let dateFormat: String = "dd/mm/yyyy"
        let timeFormat: String = "hh:mm:ss"
        let bpmFormat: String = "0"
        var totalRow: Int = 0
        var counter = seizuresOnly.count
        var lock = os_unfair_lock()
        
        seizuresOnly.forEach({ seizure in
            let predicate: NSPredicate? = HKQuery.predicateForSamples(
                withStart: seizure.startDate?.minsAgo(number: rangeMins),
                end: seizure.endDate?.addMins(number: rangeMins),
                options: HKQueryOptions.strictStartDate
            )
            let heartRateQuery = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate, limit: HKObjectQueryNoLimit,
                sortDescriptors: sortDescriptors
            ) { _, results, _ in
                guard let samples = results as? [HKQuantitySample] else {
                    return
                }
                os_unfair_lock_lock(&lock)
                let worksheet: BRAWorksheet = seizure.id == seizuresOnly.first?.id ? templateWorksheet : spreadsheet.workbook.createWorksheetNamed("Seizure\(seizure.startDate?.toDayMonthYear() ?? "noDate")", byCopying: templateWorksheet)
                var row: Int = 1
                for sample in samples.reversed() {
                    if row > maxRows {
                        break
                    }
                    row += 1
                    worksheet.cell(forCellReference: "A\(row)", shouldCreate: true).setDateValue(sample.startDate)
                    worksheet.cell(forCellReference: "A\(row)").setNumberFormat(dateFormat)
                    worksheet.cell(forCellReference: "B\(row)", shouldCreate: true).setDateValue(sample.startDate)
                    worksheet.cell(forCellReference: "B\(row)").setNumberFormat(timeFormat)
                    worksheet.cell(forCellReference: "C\(row)", shouldCreate: true).setIntegerValue(Int(sample.quantity.doubleValue(for: heartRateUnit)))
                    worksheet.cell(forCellReference: "C\(row)").setNumberFormat(bpmFormat)
                }
                totalRow += (row - 1)
                counter -= 1
                mainDebugger.append("heartRateXLSExportSeizures: counter = \(counter), elements: \(row)", .justALog)
                if counter == 0 {
                    mainDebugger.append("exit from heartRateXLSExportSeizures with \(totalRow) rows exported")
                    completion(.success(totalRow))
                }
                os_unfair_lock_unlock(&lock)
            }
            healthStore.execute(heartRateQuery)
        })
    }
}

extension ReadHealthData {
    public static func hRVExportXML(maxRows: Int, worksheet: BRAWorksheet, startDate: Date, endDate: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let hrvType = HealthQuantity.hrv.hKtype!
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let hrvUnit = HealthQuantity.hrv.hKUnit
        var row: Int = 1
        let dateFormat: String = "dd/mm/yyyy"
        let timeFormat: String = "hh:mm:ss"
        let hrvFormat: String = "0"
        
        let hrvQuery = HKSampleQuery(sampleType: hrvType,
                                     predicate: predicate, limit: HKObjectQueryNoLimit,
                                     sortDescriptors: sortDescriptors) { _, results, _ in
            guard let samples = results as? [HKQuantitySample] else {
                mainDebugger.append(Errors.noData.debugDescription, .error, sourceModule: "hRVExportXML")
                completion(.failure(Errors.noData.error))
                return
            }
            DispatchQueue.main.async {
                for sample in samples {
                    if row > maxRows {
                        completion(.success(row))
                        break
                    }
                    row += 1
                    worksheet.cell(forCellReference: "A\(row)", shouldCreate: true).setDateValue(sample.startDate)
                    worksheet.cell(forCellReference: "A\(row)").setNumberFormat(dateFormat)
                    worksheet.cell(forCellReference: "B\(row)", shouldCreate: true).setDateValue(sample.startDate)
                    worksheet.cell(forCellReference: "B\(row)").setNumberFormat(timeFormat)
                    worksheet.cell(forCellReference: "C\(row)", shouldCreate: true).setIntegerValue(Int(sample.quantity.doubleValue(for: hrvUnit)))
                    worksheet.cell(forCellReference: "C\(row)").setNumberFormat(hrvFormat)
                }
                completion(.success(row))
            }
        }
        healthStore.execute(hrvQuery)
    }
    
    public static func hRVExport(startDate: Date, endDate: Date, completion: @escaping (Result<Int, Error>, _ isShareSheetShowing: Bool) -> Void) {
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
        let hrvType = HealthQuantity.hrv.hKtype!
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let hrvUnit = HealthQuantity.hrv.hKUnit
        
        let fileName = "\(shortAppName)_HRV_SDNN_Export\(Date().toStdString()).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let newLine = "\n"
        let separator = ";"
        var csvText = "Day;Time;HRV SDNN (ms)" + newLine
        
        let heartRateQuery = HKSampleQuery(sampleType: hrvType,
                                           predicate: predicate, limit: HKObjectQueryNoLimit,
                                           sortDescriptors: sortDescriptors) { _, results, _ in
            guard let samples = results as? [HKQuantitySample] else {
                mainDebugger.append(Errors.noData.debugDescription, .error, sourceModule: "hRVExport")
                completion(.failure(Errors.noData.error), false)
                return
            }
            DispatchQueue.main.async {
                for sample in samples {
                    let date: Date = sample.startDate
                    let hrvValue: Double = sample.quantity.doubleValue(for: hrvUnit)
                    csvText += date.toDayMonthYear().prepare4CSV(separator)
                    csvText += date.toPreciseTime().prepare4CSV(separator)
                    csvText += "\(Int(hrvValue))".prepare4CSV(separator)
                    csvText += newLine
                }
                
                do {
                    try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    mainDebugger.append("Failed to create CSV file: \(error)", .error, sourceModule: "hRVExport")
                    completion(.failure(error), false)
                }
                mainDebugger.append("HRV csv exported to \(path?.absoluteString ?? "csv path not found")")
                var filesToShare = [Any]()
                filesToShare.append(path!)
                let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                av.isModalInPresentation = true
                keyWindow?.rootViewController?.present(av, animated: true)
                completion(.success(samples.count), false)
            }
        }
        healthStore.execute(heartRateQuery)
    }
}

extension ReadHealthData {
    enum Errors {
        case noData
        
        public var debugDescription: String {
            switch self {
            case .noData:
                return "No BPM data in healthkit"
            }
        }
        
        public var error: Error {
            switch self {
            case .noData:
                return NSError(domain: "HealthKitTools", code: 801, userInfo: [NSLocalizedDescriptionKey: self.debugDescription])
            }
        }
    }
}
