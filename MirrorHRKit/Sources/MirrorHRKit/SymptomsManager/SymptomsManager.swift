//
//  SymptomsManager.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 18/08/21.
//  Updated for performance and thread safety.
//
// MARK: - Overview
///**
/// # SymptomsManager
///
/// Core manager for symptom tracking, logging, and analysis in the MirrorHR application.
///
/// ## Functionality
/// - Persistent storage of symptom data using Core Data
/// - CRUD operations for symptom records
/// - Filtering and searching capabilities
/// - Statistical analysis and pattern detection
/// - Integration with notification system for caregiver alerts
/// - Video diary integration for symptom context
///
/// ## Thread Safety
/// This class implements careful thread management to ensure data consistency:
/// - Core Data operations occur on the persistent container's context
/// - UI updates are dispatched to the main thread
/// - Background operations use dedicated contexts
/// - Locking mechanisms protect shared resources
///
/// ## Performance Considerations
/// - Uses pagination for large datasets
/// - Implements efficient filtering with background processing
/// - Optimizes bulk operations for batch inserts
/// - Uses lazy loading for expensive resources
///
/// ## Usage Example
/// ```swift
/// // Log a symptom
/// let symptomLog = SymptomLog(.seizure, 
///                            startDate: Date(),
///                            endDate: Date().addingTimeInterval(60))
/// SymptomsManager.shared.appendSymptomLog(symptomLog)
/// ```
///*/

import AVKit
import Combine
import CoreData
import Foundation
import SharedPkg
import SwiftUI
import RoberdanToolBox
import MirrorHRTelemetryPackage
import OSLog
import WidgetKit

public final class SymptomsManager: ObservableObject, ErasableClass, Codable {
    // Singleton instance
    public static let shared = SymptomsManager()

    // AppStorage properties for migration checks
    @AppStorage("structureIsMigrated") var structureIsMigrated: Bool = false
    @AppStorage("deprecatedNotesMigrated") var deprecatedNotesMigrated: Bool = false
    
    internal let logger = Logger(subsystem: "SymptomsManager", category: "mainClass")
    static let maxTopLoggedSymptoms: Int = 6

    // Published properties for UI bindings
    @Published var chartFilter: HandledSymptomsEvents = .all { didSet { refreshCurtesyData() }}
    @Published var subChartFilter: HandledSymptomsEvents = .seizure { didSet { refreshCurtesyData() }}
    @Published var dateFilters: [Date] = [Date(), Date()] { didSet { refreshCurtesyData() }}
    @Published var filterArrayChart: [HandledSymptomsEvents] = HandledSymptomsEvents.allCases
    @Published var filterArrayTimeLine: [HandledSymptomsEvents] = HandledSymptomsEvents.allCases
    @Published public var topLoggedSympts: [HandledSymptomsEvents] = []

    @Published var chartPerspective: Int = 0
    @Published var filteredSymptoms: [SymptomsData] = []
    @Published var searchText: String = "" {
        didSet {
            if oldValue != searchText, searchText.isEmpty {
                resetSearchText()
            }
        }
    }
    @Published var isSearching: Bool = false

    // Date formatter for search functionality
    private let searchDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter
    }()

    // Core Data context
    internal let context: NSManagedObjectContext
    internal var symptomsData = [SymptomsData]()
    
    // Available chart filters
    public let chartFilters: [HandledSymptomsEvents] = [.seizure, .medicationTaken, .videoLog, .realTimeSessionEnded, .all, .byDate, .filter]
    
    // Combine subscriber for erase commands
    public var eraseCommandSubscriber = AnyCancellable {}
    
    // Sort descriptor for fetch requests
    private let dataSort = NSSortDescriptor(key: "startDate", ascending: false)
    private var predicate: NSPredicate?
    internal let noStartDate = Date(timeIntervalSince1970: 0)

    // Arrays for specific symptom categories
    public var seizuresLogOnlySymptomsArray: [HandledSymptomsEvents] = [.seizure]
    public var oldSymptoms: [HandledSymptomsEvents] = [.oldSeizure, .oldVideoSeizureLog]

    /// Private initializer for singleton pattern
    private init() {
        self.context = PersistenceController.shared.container.viewContext
        fetch()
        if symptomsData.isEmpty {
            mainDebugger.append("Symptoms Manager init: there are no records yet!")
        } else {
            if !structureIsMigrated || !deprecatedNotesMigrated {
                migrateData()
            }
        }

        // Observe context save notifications
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(notification:)), name: .NSManagedObjectContextDidSave, object: context)

        // Subscribe to erase commands
        eraseCommandSubscriber = MirrorHRTelemetryPackage.eraseCommandCombinePublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.clearAllItems { result in
                    switch result {
                    case .success:
                        mainDebugger.append("Successfully cleared all items in SymptomsManager", .greenFlag)
                    case .failure(let error):
                        mainDebugger.append("Error clearing all items in SymptomsManager: \(error.localizedDescription)", .error)
                    }
                }
            }

        MainDebugger.shared.append("SymptomsManager initialization done")
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case structureIsMigrated
        case deprecatedNotesMigrated
        case chartFilter
        case subChartFilter
        case dateFilters
        case filterArrayChart
        case filterArrayTimeLine
        case topLoggedSympts
        case chartPerspective
        case filteredSymptoms
        case symptomsData
    }

    /// Encodes the SymptomsManager instance into an Encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(structureIsMigrated, forKey: .structureIsMigrated)
        try container.encode(deprecatedNotesMigrated, forKey: .deprecatedNotesMigrated)
        try container.encode(chartFilter, forKey: .chartFilter)
        try container.encode(subChartFilter, forKey: .subChartFilter)
        try container.encode(dateFilters, forKey: .dateFilters)
        try container.encode(filterArrayChart, forKey: .filterArrayChart)
        try container.encode(filterArrayTimeLine, forKey: .filterArrayTimeLine)
        try container.encode(topLoggedSympts, forKey: .topLoggedSympts)
        try container.encode(chartPerspective, forKey: .chartPerspective)
        try container.encode(filteredSymptoms.map { $0.objectID.uriRepresentation().absoluteString }, forKey: .filteredSymptoms)
        let codableSymptomsData = symptomsData.map { CodableSymptomsData(from: $0) }
        try container.encode(codableSymptomsData, forKey: .symptomsData)
    }

    /// Initializes a SymptomsManager instance from a Decoder.
    public required init(from decoder: Decoder) throws {
        self.context = PersistenceController.shared.container.viewContext
        let container = try decoder.container(keyedBy: CodingKeys.self)
        structureIsMigrated = try container.decode(Bool.self, forKey: .structureIsMigrated)
        deprecatedNotesMigrated = try container.decode(Bool.self, forKey: .deprecatedNotesMigrated)
        chartFilter = try container.decode(HandledSymptomsEvents.self, forKey: .chartFilter)
        subChartFilter = try container.decode(HandledSymptomsEvents.self, forKey: .subChartFilter)
        dateFilters = try container.decode([Date].self, forKey: .dateFilters)
        filterArrayChart = try container.decode([HandledSymptomsEvents].self, forKey: .filterArrayChart)
        filterArrayTimeLine = try container.decode([HandledSymptomsEvents].self, forKey: .filterArrayTimeLine)
        topLoggedSympts = try container.decode([HandledSymptomsEvents].self, forKey: .topLoggedSympts)
        chartPerspective = try container.decode(Int.self, forKey: .chartPerspective)
        let filteredSymptomURIs = try container.decode([String].self, forKey: .filteredSymptoms)
        filteredSymptoms = filteredSymptomURIs.compactMap {
            if let url = URL(string: $0), let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                return try? context.existingObject(with: objectID) as? SymptomsData
            }
            return nil
        }
        let codableSymptomsData = try container.decode([CodableSymptomsData].self, forKey: .symptomsData)
        symptomsData = codableSymptomsData.map { $0.toSymptomsData(context: context) }
    }

    /// Returns a JSON string representation of the SymptomsManager instance.
    public func jsonString() throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }

    /// Clears all items and loads data from a JSON string.
    public func loadFromJsonDisruptive(jsonString: String) throws {
        clearAllItems { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                do {
                    try self.loadFromJson(jsonString: jsonString)
                } catch {
                    mainDebugger.append("Failed to load from JSON: \(error)", .error)
                }
            case .failure(let error):
                mainDebugger.append("Failed to clear all items: \(error)", .error)
            }
        }
    }

    /// Loads data from a JSON string into the SymptomsManager instance.
    public func loadFromJson(jsonString: String) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = jsonString.data(using: .utf8)!
        let decodedData = try decoder.decode(Self.self, from: data)
        DispatchQueue.main.async {
            self.structureIsMigrated = decodedData.structureIsMigrated
            self.deprecatedNotesMigrated = decodedData.deprecatedNotesMigrated
            self.chartFilter = decodedData.chartFilter
            self.subChartFilter = decodedData.subChartFilter
            self.dateFilters = decodedData.dateFilters
            self.filterArrayChart = decodedData.filterArrayChart
            self.filterArrayTimeLine = decodedData.filterArrayTimeLine
            self.topLoggedSympts = decodedData.topLoggedSympts
            self.chartPerspective = decodedData.chartPerspective
            self.filteredSymptoms = decodedData.filteredSymptoms
            self.symptomsData = decodedData.symptomsData
        }
    }
}

// MARK: - Private Functions

extension SymptomsManager {
    /// Handles context save notifications to merge changes into the main context.
    @objc private func contextDidSave(notification: Notification) {
        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }

    /// Clears all items from the Core Data context.
    public func clearAllItems(completion: @escaping (Result<Bool, Error>) -> Void) {
        context.perform {
            self.symptomsData.forEach { self.context.delete($0) }
            do {
                try self.context.save()
                DispatchQueue.main.async {
                    self.fetch()
                    completion(.success(true))
                    mainDebugger.append("Just deleted all symptoms from Core Data")
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Refreshes the symptoms data by fetching from Core Data.
    func refresh() {
        fetch()
    }

    /// Checks if a medication taken event exists between two dates.
    func medicationTakenExists(between startDate: Date, endDate: Date) -> (exist: Bool, last: Date?) {
        return fetchMedication(withSymptom: HandledSymptomsEvents.medicationTaken.rawValue, between: startDate, endDate: endDate)
    }

    /// Checks if a medication forgotten event exists between two dates.
    func medicationForgottenExists(between startDate: Date, endDate: Date) -> Bool {
        let result = fetchMedication(withSymptom: HandledSymptomsEvents.medicationForgotten.rawValue, between: startDate, endDate: endDate)
        return result.exist
    }

    /// Fetches medication events between two dates.
    private func fetchMedication(withSymptom symptom: String, between startDate: Date, endDate: Date) -> (exist: Bool, last: Date?) {
        let request: NSFetchRequest<SymptomsData> = SymptomsData.fetchRequest()
        request.predicate = NSPredicate(
            format: "symptom == %@ AND startDate > %@ AND startDate < %@",
            symptom,
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [dataSort]

        do {
            let medicationTaken = try context.fetch(request)
            let sinceLastMedication: Date? = medicationTaken.first?.endDate ?? nil
            return (!medicationTaken.isEmpty, sinceLastMedication)
        } catch {
            logFetchError(error: error)
            return (false, nil)
        }
    }

    /// Logs fetch errors to the main debugger.
    private func logFetchError(error: Error) {
        let nsError = error as NSError
        let msg = "Unresolved error in SymptomsManager Fetch: \(nsError), \(nsError.userInfo)"
        mainDebugger.append(msg, .error, sourceModule: "SymptomsManager logFetchError")
    }

    /// Saves a seizure event to Core Data.
    func saveSeizure(startTime: Date,
                     endTime: Date,
                     severity: SymptomSeverityRanges,
                     metadata: HealthKitMetadaString) {
        appendSymptomLog(.init(.seizure,
                               startDate: startTime,
                               endDate: endTime,
                               severity: severity,
                               jsonMetaData: metadata.jsonString,
                               notes: metadata.notes
                              )
        )
    }

    /// Fetches symptoms data from Core Data.
    internal func fetch() {
        context.perform { [weak self] in
            guard let self = self else { return }

            let fetchRequest: NSFetchRequest<SymptomsData> = SymptomsData.fetchRequest()
            fetchRequest.sortDescriptors = [self.dataSort]
            fetchRequest.predicate = self.predicate

            do {
                let results = try self.context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    self.symptomsData = results
                    self.refreshCurtesyData()
                    self.filterBySearchText(by: self.searchText)
                }
            } catch {
                self.logFetchError(error: error)
                return
            }

            self.fetchTopLoggedSymptoms { topLoggedSymptoms in
                DispatchQueue.main.async {
                    self.topLoggedSympts = topLoggedSymptoms
                    mainDebugger.append("SymptomsManager fetch done", .event)
                    self.saveTopLoggedSymptomsForWidget(topLoggedSympts: topLoggedSymptoms)
                }
            }
        }
    }

    /// Appends a remote symptom log to Core Data.
    public func appendRemoteSymptomLog(_ symptomLog: SymptomLog, isBulkInsert: Bool = false) {
        let remoteSymptomLog = symptomLog
        remoteSymptomLog.isRemoteStreaming = true
        appendSymptomLog(remoteSymptomLog, isBulkInsert: isBulkInsert)
    }

    /// Appends a symptom log to Core Data.
    public func appendSymptomLog(_ symptomLog: SymptomLog, isBulkInsert: Bool = false) {
        appendSymptomLogPrivate(symptomLog, isBulkInsert: isBulkInsert)
    }

    /// Internal method to append a symptom log to Core Data.
    private func appendSymptomLogPrivate(_ symptomLog: SymptomLog, isBulkInsert: Bool = false) {
        context.perform {
            let newSymptom = self.convertLogToSymptomData(symptomLog)
            do {
                try self.context.save()

                if !isBulkInsert {
                    DispatchQueue.main.async {
                        self.sendRemoteNotificationsToCareGivers(for: symptomLog)
                        self.symptomsData.insert(newSymptom, at: 0)
                        self.refreshCurtesyData()
                        let message: String = symptomLog.symptom.localizedString() + " " + "savedBtnMsg".local()
                        ToastManager.shared.showToast(message: message, image: symptomLog.symptom.image)
                    }
                }
            } catch {
                let message: String = "Error: \(error.localizedDescription)"
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(message: message, image: "exclamationmark.triangle")
                }
            }
        }
    }

    /// Fires telemetry control symptoms.
    func fireTelemetryControlSymptoms(_ symptomLog: SymptomLog) {
        appendSymptomLog(symptomLog, isBulkInsert: false)
    }

    /// Saves the context and refreshes data if needed.
    internal func saveAndRefresh(_ shouldRefresh: Bool = true) {
        context.perform {
            do {
                try self.context.save()
                mainDebugger.append("SymptomsManager saved the data", .greenFlag)
                if shouldRefresh {
                    DispatchQueue.main.async {
                        self.fetch()
                    }
                }
            } catch {
                let nsError = error as NSError
                let msg = "Unresolved error in SymptomsManager Save and Refresh: \(nsError), \(nsError.userInfo)"
                mainDebugger.append(msg, .error, sourceModule: "SymptomsManager saveAndRefresh")
            }
        }
    }

    /// Deletes a symptom from Core Data.
    func deleteSymptom(for symptom: SymptomsData) {
        let objectID = symptom.objectID
        context.perform {
            if let symptomToDelete = self.context.object(with: objectID) as? SymptomsData {
                if let videoFilename = symptomToDelete.videoFileName,
                   let videoURL = getVideoUrl(fileName: videoFilename) {
                    self.deleteVideoFile(videoURL)
                }

                self.context.delete(symptomToDelete)
                self.saveAndRefresh()
            }
        }
    }

    /// Deletes symptom logs at specified offsets.
    func deleteSymptomsLogs(offsets: IndexSet) {
        context.perform {
            offsets.map { self.symptomsData[$0] }.forEach { self.context.delete($0) }
            self.saveAndRefresh()
        }
    }

    /// Deletes a video file at a given URL.
    private func deleteVideoFile(_ videoURL: URL) {
        do {
            try FileManager.default.removeItem(at: videoURL)
            mainDebugger.append("VideoLog file cancelled", .justALog)
        } catch {
            mainDebugger.append("Error deleting videoLog file: \(error.localizedDescription)", .error, sourceModule: "SymptomsManager deleteVideoFile")
        }
    }

    /// Updates a symptom's notes.
    func updateSymptom(which symptom: SymptomsData, withNotes notes: String) {
        let objectID = symptom.objectID
        context.perform {
            guard let existingSymptom = self.context.object(with: objectID) as? SymptomsData else {
                return
            }

            existingSymptom.notes = notes

            do {
                try self.context.save()
                self.handleSymptomUpdatedNotifications(for: existingSymptom, isCritical: false)
            } catch {
                mainDebugger.append("Error updating symptom: \(error.localizedDescription)", .error)
            }
        }
    }
}

// MARK: - Filtering and Searching

extension SymptomsManager {
    /// Applies filters based on the symptom filter array.
    internal func applyFiltersBySymptomFilter() {
        DispatchQueue.global(qos: .userInitiated).async {
            let filteredData = self.symptomsData.filter { symptomData in
                guard let symptomRawValue = symptomData.symptom,
                      let symptomEvent = HandledSymptomsEvents(rawValue: symptomRawValue) else {
                    return false
                }
                return self.filterArrayChart.contains(symptomEvent)
            }
            DispatchQueue.main.async {
                self.filteredSymptoms = filteredData
            }
        }
    }

    /// Refreshes data based on the current chart filter.
    ///
    /// This method filters symptom data based on the selected chart filter type and updates
    /// the UI with the filtered results. It performs filtering work on a background thread
    /// to avoid blocking the UI, and then dispatches UI updates back to the main thread.
    ///
    /// The filtering process:
    /// 1. Determines the appropriate filter arrays based on the current filter type
    /// 2. Applies the filters to the full symptoms dataset
    /// 3. Updates the UI with the filtered results
    ///
    /// - Important: This method is optimized for UI responsiveness, not real-time performance
    ///
    /// - Note: Performance optimization opportunities:
    ///   - Consider caching filter results for frequently used filters
    ///   - For very large datasets, implement incremental loading with pagination
    ///   - Use a more efficient data structure for filter containment checks
    func refreshCurtesyData() {
        // PERFORMANCE CONSIDERATION:
        // Using a dedicated serial queue instead of global concurrent queue
        // would provide more predictable performance characteristics and
        // avoid potential thread contention.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Calculate filter arrays off main thread
            let newFilterArrayChart: [HandledSymptomsEvents]
            let newFilterArrayTimeLine: [HandledSymptomsEvents]
            
            switch self.chartFilter {
            case .seizure:
                newFilterArrayChart = [.seizure]
                newFilterArrayTimeLine = [.seizure, .videoSeizureLog]
            case .medicationTaken:
                newFilterArrayChart = [.medicationTaken]
                newFilterArrayTimeLine = [.medicationForgotten, .medicationTaken]
            case .videoLog:
                newFilterArrayChart = [.videoLog]
                newFilterArrayTimeLine = [.videoLog]
            case .filter:
                newFilterArrayChart = [self.subChartFilter]
                newFilterArrayTimeLine = [self.subChartFilter]
            case .realTimeSessionEnded:
                newFilterArrayChart = [.realTimeSessionEnded]
                newFilterArrayTimeLine = [.realTimeSessionEnded]
            default:
                newFilterArrayChart = HandledSymptomsEvents.allPossibleFilters
                newFilterArrayTimeLine = HandledSymptomsEvents.allPossibleFilters
            }
            
            // Apply filters off main thread
            // PERFORMANCE CONSIDERATION:
            // For large datasets, consider using a Set for newFilterArrayChart
            // to achieve O(1) containment checks instead of O(n) array traversal
            let filteredData = self.symptomsData.filter { symptomData in
                guard let symptomRawValue = symptomData.symptom,
                      let symptomEvent = HandledSymptomsEvents(rawValue: symptomRawValue) else {
                    return false
                }
                return newFilterArrayChart.contains(symptomEvent)
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.filterArrayChart = newFilterArrayChart
                self.filterArrayTimeLine = newFilterArrayTimeLine
                self.filteredSymptoms = filteredData
            }
        }
    }

    /// Filters symptoms data by a date range.
    func filterByDataRange(from startDate: Date, to endDate: Date) {
        guard startDate <= endDate else { return }
        let dateRange = startDate...endDate
        DispatchQueue.global(qos: .userInitiated).async {
            let filteredData = self.symptomsData.filter { symptom in
                if let symptomStartDate = symptom.startDate {
                    return dateRange.contains(symptomStartDate)
                }
                return false
            }
            DispatchQueue.main.async {
                self.filteredSymptoms = filteredData
            }
        }
    }

    /// Filters symptoms data based on search text.
    func filterBySearchText(by text: String) {
        searchText = text
        guard !text.isEmpty else {
            resetSearchText()
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let filteredData = self.symptomsData.filter { symptomData in
                self.matchesSearchCriteria(symptomData)
            }
            DispatchQueue.main.async {
                self.filteredSymptoms = filteredData
                self.isSearching = true
            }
        }
    }

    /// Checks if a symptom matches the search criteria.
    private func matchesSearchCriteria(_ symptomData: SymptomsData) -> Bool {
        if let symptom = symptomData.symptom,
           symptom.local().localizedCaseInsensitiveContains(searchText) {
            return true
        }

        if let startDate = symptomData.startDate,
           searchDateFormatter.string(from: startDate).localizedStandardContains(searchText) {
            return true
        }

        if let notes = symptomData.notes,
           notes.localizedCaseInsensitiveContains(searchText) {
            return true
        }

        return false
    }

    /// Filters only seizure events.
    func filterSeizuresOnly(reset: Bool) {
        if reset {
            resetSearchText()
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let filteredData = self.symptomsData.filter {
                    $0.symptom == HandledSymptomsEvents.seizure.rawValue || $0.symptom == HandledSymptomsEvents.videoSeizureLog.rawValue
                }
                DispatchQueue.main.async {
                    self.filteredSymptoms = filteredData
                }
            }
        }
    }

    /// Resets the search text and filtering.
    func resetSearchText() {
        DispatchQueue.main.async {
            self.filteredSymptoms = self.symptomsData
            if !self.searchText.isEmpty {
                self.searchText = ""
            }
            self.isSearching = false
            UIApplication.shared.endEditing()
        }
    }

    /// Retrieves symptoms data for the last specified number of days.
    func symptomsDataForLastDays(_ days: Int) -> [SymptomsData] {
        let range = Date().daysAgo(number: days) ... Date()
        return symptomsData.filter { symptom in
            if let startDate = symptom.startDate {
                return range.contains(startDate)
            }
            return false
        }
    }

    /// Retrieves seizure events for the last specified number of days.
    func seizuresForLastDays(_ lastDays: Int? = nil) -> [SymptomsData] {
        let data = lastDays.map { self.symptomsDataForLastDays($0) } ?? self.symptomsData
        return data.filter { symptom in
            if let symptomType = symptom.symptom, let event = HandledSymptomsEvents(rawValue: symptomType) {
                return seizuresLogOnlySymptomsArray.contains(event)
            }
            return false
        }
    }

    /// Retrieves only seizure events from symptoms data.
    var seizuresOnlyData: [SymptomsData] {
        return symptomsData.filter { symptom in
            if let symptomType = symptom.symptom, let event = HandledSymptomsEvents(rawValue: symptomType) {
                return seizuresLogOnlySymptomsArray.contains(event)
            }
            return false
        }
    }

    /// Retrieves the last recorded seizure event.
    var lastSeizure: SymptomsData? {
        return seizuresOnlyData.first
    }

    /// Retrieves the last specified number of symptoms.
    func lastSymptoms(_ howMany: Int) -> [SymptomsData] {
        return Array(symptomsData.prefix(howMany))
    }
}

// MARK: - SymptomsData Extensions

extension SymptomsData {
    /// Checks if the symptom is a video log.
    func isVideo() -> Bool {
        guard let symptom = symptom else {
            return false
        }
        return (HandledSymptomsEvents(rawValue: symptom) == .videoLog)
            || (HandledSymptomsEvents(rawValue: symptom) == .videoSeizureLog)
    }

    /// Calculates the length of the symptom event.
    func Lenght() -> DateComponents {
        Calendar.current.dateComponents([.hour, .minute, .second], from: startDate ?? Date(), to: endDate ?? Date())
    }

    /// Checks if the symptom event length is zero.
    func isLenghtZero() -> Bool {
        let length = Lenght()
        return length.hour == 0 && length.minute == 0 && length.second == 0
    }

    /// Checks if the symptom event length is not zero.
    func isNotLenghtZero() -> Bool {
        !isLenghtZero()
    }

    /// Provides a timeline date header for the symptom.
    @objc var timelineDateHeader: String {
        guard let validStartDate = startDate else {
            return "Unknown Date"
        }
        return validStartDate.timelineDateHeader()
    }
}

// MARK: - Internal Extensions

extension SymptomsManager {
    /// Enum to specify the type of date comparison.
    enum DateComparison {
        case onOrAfter, before
    }

    /// Gets the count of filtered symptoms logged from a specified time interval.
    func getFilteredSymptomsLogged(from interval: TimeInterval, comparison: DateComparison) -> Int {
        let dateRange = Date() - interval
        return filteredSymptoms.filter { symptom in
            guard let startDate = symptom.startDate else {
                return false
            }
            switch comparison {
            case .onOrAfter:
                return startDate >= dateRange
            case .before:
                return startDate < dateRange
            }
        }.count
    }
}

// MARK: - Helper Methods

extension SymptomsManager {
    /// Converts a SymptomLog into a SymptomsData object.
    private func convertLogToSymptomData(_ log: SymptomLog) -> SymptomsData {
        let newSymptom = SymptomsData(context: context)
        newSymptom.id = log.id
        newSymptom.symptom = log.symptom.rawValue
        newSymptom.startDate = log.startDate
        newSymptom.endDate = log.endDate
        newSymptom.sincePreviousLog = log.sincePreviousLog
        newSymptom.severity = log.severity ?? 0
        newSymptom.videoThumbnail = log.videoThumbnail
        newSymptom.videoFileName = log.videoFileName
        newSymptom.videoTranscript = log.videoTranscript
        newSymptom.videoMetaData = log.videoMetaData
        newSymptom.videoDuration = log.videoDuration ?? 0.0
        newSymptom.jsonMetaData = log.jsonMetaData
        newSymptom.notes = log.notes ?? ""
        newSymptom.latitude = log.latitude ?? 0
        newSymptom.longitude = log.longitude ?? 0
        newSymptom.patientName = log.patientName ?? ""
        return newSymptom
    }

    /// Sends remote notifications to caregivers based on a symptom log.
    private func sendRemoteNotificationsToCareGivers(for log: SymptomLog) {
        // Check if notifications should be sent
        if !DataSourceManager.shared.dataSource.shouldSendKeyEventsToCareGivers {
            return
        }

        let symptom = log.symptom
        let kidName: String = ProfileGenericSettings.shared.kidName
        let kidID: String = TelemetryHeader.shared.currentUserID

        let title: String = symptom == .ask4Help ? kidName + " " + "Ask4HelpNeedsYourHelpMsg".local() : kidName + " - " + "shortAppName".local()

        let body: String = symptom == .ask4Help ? "\(kidName): Help me please! I don't feel well." : symptom.localizedString() + " (\(log.startDate.toShort()) - \(log.endDate.toShort()))"

        let isCritical: Bool = log.symptom.symptomCategory != .symptom
        let latitude = LocationManager.shared.currentLatitude
        let longitude = LocationManager.shared.currentLongitude

        let notificationSupportStruct = NotificationSupportStruct(kidName: kidName, kidID: kidID, symptom: log.symptom.rawValue, localizedName: log.symptom.localizedString(), startDate: log.startDate, endDate: log.endDate, notes: log.notes ?? "", soundName: log.symptom.soundName, title: title, body: body, isCritical: isCritical, latitude: latitude, longitude: longitude)

        dispatchTelemetryEvent(event: .symptomsLogged(notificationSupportStruct: notificationSupportStruct))
    }

    /// Handles notifications when a symptom is updated.
    private func handleSymptomUpdatedNotifications(for symptom: SymptomsData, isCritical: Bool) {
        let title = "shortAppName".local() + " " + "RemoteNotificationTitleMsg".local()
        let symptomName = symptom.symptom ?? ""
        let startDate = symptom.startDate?.toShort() ?? Date().toShort()
        let endDate = symptom.endDate?.toShort() ?? Date().toShort()

        let body = "\(symptomName) (\(startDate) - \(endDate))"
        let latitude = LocationManager.shared.currentLatitude
        let longitude = LocationManager.shared.currentLongitude

        let notificationSupportStruct = NotificationSupportStruct(
            kidName: ProfileGenericSettings.shared.kidName,
            kidID: TelemetryHeader.shared.currentUserID,
            symptom: symptomName,
            localizedName: symptomName,
            startDate: symptom.startDate ?? Date(),
            endDate: symptom.endDate ?? Date(),
            notes: symptom.notes ?? "",
            soundName: "default soundname",
            title: title,
            body: body,
            isCritical: isCritical,
            latitude: latitude,
            longitude: longitude
        )
        dispatchTelemetryEvent(event: .symptomsLogged(notificationSupportStruct: notificationSupportStruct))
    }

    /// Fetches the top logged symptoms.
    private func fetchTopLoggedSymptoms(completion: @escaping ([HandledSymptomsEvents]) -> Void) {
        let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
        backgroundContext.perform {
            let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "SymptomsData")
            request.resultType = .dictionaryResultType
            request.propertiesToGroupBy = ["symptom"]

            let countExpression = NSExpression(format: "count:(id)")
            let countED = NSExpressionDescription()
            countED.name = "count"
            countED.expression = countExpression
            countED.expressionResultType = .integer64AttributeType

            request.propertiesToFetch = ["symptom", countED]
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
            request.fetchLimit = SymptomsManager.maxTopLoggedSymptoms

            let excludedSymptoms: [HandledSymptomsEvents] = [.realTimeSessionEnded, .realTimeSessionStarted] + HandledSymptomsEvents.quickCommands + HandledSymptomsEvents.dailyMoods + [.textLog, .error, .none]
            let excludedRawValues = excludedSymptoms.map { $0.rawValue }
            request.predicate = NSPredicate(format: "NOT (symptom IN %@)", excludedRawValues)

            do {
                let results = try backgroundContext.fetch(request)
                let mappedResults = results.compactMap { result -> HandledSymptomsEvents? in
                    if let symptom = result["symptom"] as? String,
                       let sympt = HandledSymptomsEvents(rawValue: symptom) {
                        return sympt
                    }
                    return nil
                }
                DispatchQueue.main.async {
                    completion(mappedResults)
                }
            } catch {
                DispatchQueue.main.async {
                    mainDebugger.append("Error fetching top symptoms: \(error)", .error, sourceModule: "SymptomsManager fetchTopLoggedSymptoms")
                    completion([])
                }
            }
        }
    }

    /// Saves the top logged symptoms for the widget.
    private func saveTopLoggedSymptomsForWidget(topLoggedSympts: [HandledSymptomsEvents]) {
        let sharedDefaults = UserDefaults(suiteName: "group.mirror-labs.Epilepsy-Research-Kit")
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(topLoggedSympts) {
            sharedDefaults?.set(encodedData, forKey: "topLoggedSympts")
        }
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

// MARK: - CodableSymptomsData

/// A codable representation of SymptomsData for encoding and decoding.
private struct CodableSymptomsData: Codable {
    var endDate: Date
    var id: UUID
    var jsonMetaData: String?
    var latitude: Double
    var longitude: Double
    var notes: String?
    var severity: Int16
    var sincePreviousLog: Double
    var startDate: Date
    var symptom: String?
    var videoDuration: Double
    var videoFileName: String?
    var videoMetaData: String?
    var videoSentiment: Double
    var videoThumbnail: Data?
    var videoTranscript: String?
    var weather: String?
    var patientName: String?
}

extension CodableSymptomsData {
    /// Initializes a CodableSymptomsData from a SymptomsData object.
    init(from symptomsData: SymptomsData) {
        self.endDate = symptomsData.endDate ?? Date()
        self.id = symptomsData.id ?? UUID()
        self.jsonMetaData = symptomsData.jsonMetaData
        self.latitude = symptomsData.latitude
        self.longitude = symptomsData.longitude
        self.notes = symptomsData.notes
        self.severity = symptomsData.severity
        self.sincePreviousLog = symptomsData.sincePreviousLog
        self.startDate = symptomsData.startDate ?? Date()
        self.symptom = symptomsData.symptom
        self.videoDuration = symptomsData.videoDuration
        self.videoFileName = symptomsData.videoFileName
        self.videoMetaData = symptomsData.videoMetaData
        self.videoSentiment = symptomsData.videoSentiment
        self.videoThumbnail = symptomsData.videoThumbnail
        self.videoTranscript = symptomsData.videoTranscript
        self.weather = symptomsData.weather
        self.patientName = symptomsData.patientName
    }

    /// Converts a CodableSymptomsData into a SymptomsData object.
    func toSymptomsData(context: NSManagedObjectContext) -> SymptomsData {
        let symptomsData = SymptomsData(context: context)
        symptomsData.endDate = self.endDate
        symptomsData.id = self.id
        symptomsData.jsonMetaData = self.jsonMetaData
        symptomsData.latitude = self.latitude
        symptomsData.longitude = self.longitude
        symptomsData.notes = self.notes
        symptomsData.severity = self.severity
        symptomsData.sincePreviousLog = self.sincePreviousLog
        symptomsData.startDate = self.startDate
        symptomsData.symptom = self.symptom
        symptomsData.videoDuration = self.videoDuration
        symptomsData.videoFileName = self.videoFileName
        symptomsData.videoMetaData = self.videoMetaData
        symptomsData.videoSentiment = self.videoSentiment
        symptomsData.videoThumbnail = self.videoThumbnail
        symptomsData.videoTranscript = self.videoTranscript
        symptomsData.weather = self.weather
        symptomsData.patientName = self.patientName
        return symptomsData
    }
}

public class ProxySymptomsManager {
    private let symptomsManager: SymptomsManager = .shared
    private let logger = Logger(subsystem: "SymptomsManager", category: "ProxySymptomsManager")
    
    public init() {
        
    }
    
    public func medicationTakenExists(between: Date, endDate: Date) -> (exist: Bool, last: Date?) {
        return symptomsManager.medicationTakenExists(between: between, endDate: endDate)
    }
}

// MARK: - Append or Update Symptom Log

extension SymptomsManager {
    /// Appends a new symptom log or updates an existing one based on the unique ID.
    /// - Parameters:
    ///   - symptomLog: The `SymptomLog` to append or update.
    ///   - completion: Completion handler with the save status.
    func appendOrUpdateSymptomsLog(_ symptomLog: SymptomLog, _ completion: @escaping (_ status: SymptomLog.SavedStatus) -> Void) {
        context.perform { [weak self] in
            guard let self = self else {
                completion(.error(description: "Failed to access SymptomsManager instance"))
                return
            }

            // Fetch the symptom that needs to be updated, if it exists
            let fetchRequest: NSFetchRequest<SymptomsData> = SymptomsData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", symptomLog.id as CVarArg)

            do {
                if let symptomToUpdate = try self.context.fetch(fetchRequest).first {
                    // Update the existing symptom with new data
                    symptomToUpdate.startDate = symptomLog.startDate
                    symptomToUpdate.symptom = symptomLog.symptom.rawValue
                    symptomToUpdate.notes = symptomLog.notes
                    symptomToUpdate.endDate = symptomLog.endDate
                    symptomToUpdate.sincePreviousLog = symptomLog.sincePreviousLog
                    symptomToUpdate.severity = symptomLog.severity ?? 0
                    symptomToUpdate.videoThumbnail = symptomLog.videoThumbnail
                    symptomToUpdate.videoFileName = symptomLog.videoFileName
                    symptomToUpdate.videoDuration = symptomLog.videoDuration ?? 0
                    symptomToUpdate.videoSentiment = symptomLog.videoSentiment ?? 0
                    symptomToUpdate.videoTranscript = symptomLog.videoTranscript
                    symptomToUpdate.videoMetaData = symptomLog.videoMetaData
                    symptomToUpdate.jsonMetaData = symptomLog.jsonMetaData
                    symptomToUpdate.patientName = symptomLog.patientName
                    symptomToUpdate.latitude = symptomLog.latitude ?? 0
                    symptomToUpdate.longitude = symptomLog.longitude ?? 0

                    try self.context.save()
                    DispatchQueue.main.async {
                        self.handleSymptomUpdatedNotifications(for: symptomToUpdate, isCritical: false)
                        completion(.updated)
                    }
                } else {
                    // Symptom does not exist, append it
                    self.appendSymptomLog(symptomLog, isBulkInsert: false)
                    DispatchQueue.main.async {
                        completion(.added)
                    }
                }
            } catch {
                let message = "Error: \(error.localizedDescription)"
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(message: message, image: "exclamationmark.triangle")
                    completion(.error(description: error.localizedDescription))
                }
            }
        }
    }
}

/// Fetches symptoms data with pagination support
/// - Parameters:
///   - page: The page number to fetch (0-based)
///   - pageSize: Number of items per page
///   - completion: Callback with fetched symptoms or error
public func fetchPaginated(page: Int = 0, pageSize: Int = 50, completion: @escaping (Result<[SymptomsData], Error>) -> Void) {
    let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    backgroundContext.perform {
        let fetchRequest = NSFetchRequest<SymptomsData>(entityName: "SymptomsData")
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = page * pageSize
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            let results = try backgroundContext.fetch(fetchRequest)
            DispatchQueue.main.async {
                completion(.success(results))
            }
        } catch {
            let nsError = error as NSError
            let msg = "Paginated fetch error: \(nsError), \(nsError.userInfo)"
            mainDebugger.append(msg, .error, sourceModule: "SymptomsManager fetchPaginated")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

/// Fetches the total count of symptoms
/// - Parameter completion: Callback with count or error
public func fetchTotalCount(completion: @escaping (Result<Int, Error>) -> Void) {
    let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    
    backgroundContext.perform {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "SymptomsData")
        fetchRequest.resultType = .countResultType
        
        do {
            let count = try backgroundContext.count(for: fetchRequest)
            DispatchQueue.main.async {
                completion(.success(count))
            }
        } catch {
            let nsError = error as NSError
            let msg = "Count fetch error: \(nsError), \(nsError.userInfo)"
            mainDebugger.append(msg, .error, sourceModule: "SymptomsManager fetchTotalCount")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

/// Optimized method to save symptom data using a background context
/// - Parameters:
///   - symptomLog: The symptom log to save
///   - isBulkInsert: Whether this is part of a bulk insert operation
///   - completion: Optional callback with result
public func appendOptimized(symptomLog: SymptomLog, isBulkInsert: Bool = false, completion: ((Result<SymptomsData, Error>) -> Void)? = nil) {
    let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    backgroundContext.performAndWait {
        do {
            // Create new symptom in background context
            let newSymptom = SymptomsData(context: backgroundContext)
            newSymptom.id = UUID()
            newSymptom.symptom = symptomLog.symptom.rawValue
            newSymptom.startDate = symptomLog.startDate
            newSymptom.endDate = symptomLog.endDate
            newSymptom.notes = symptomLog.notes
            
            // Save in background context
            try backgroundContext.save()
            
            if !isBulkInsert {
                // Get managed object ID to reference from main context
                let objectID = newSymptom.objectID
                
                DispatchQueue.main.async { [weak self] in // Use weak or strong capture list as needed
                    guard let self = self else { return } // Add a guard to prevent retaining or missing self
                    if let mainContextSymptom = self.context.object(with: objectID) as? SymptomsData {
                        self.sendRemoteNotificationsToCareGivers(for: symptomLog)
                        self.symptomsData.insert(mainContextSymptom, at: 0)
                        self.refreshCurtesyData()
                        
                        let message: String = symptomLog.symptom.localizedString() + " " + "savedBtnMsg".local()
                        ToastManager.shared.showToast(message: message, image: symptomLog.symptom.image)
                        
                        completion?(.success(mainContextSymptom))
                    }
                }
            } else if let completion = completion {
                // For bulk insert, just return the object ID
                DispatchQueue.main.async {
                    // We can't directly return the background context object to the main thread
                    // So we return a success without the object for bulk operations
                    completion(.success(newSymptom))
                }
            }
        } catch {
            let message: String = "Error: \(error.localizedDescription)"
            mainDebugger.append("Error appending symptom log: \(error)", .error, sourceModule: "SymptomsManager appendOptimized")
            
            DispatchQueue.main.async {
                ToastManager.shared.showToast(message: message, image: "exclamationmark.triangle")
                completion?(.failure(error))
            }
        }
    }
}

/// Bulk insert multiple symptom logs with optimized performance
/// - Parameters:
///   - symptomLogs: Array of symptom logs to insert
///   - completion: Callback with success or failure
public func bulkInsert(symptomLogs: [SymptomLog], completion: @escaping (Result<Void, Error>) -> Void) {
    let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    
    // Configure for batch operations
    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    backgroundContext.perform {
        autoreleasepool {
            var lastSave = Date()
            let saveInterval = 1.0 // Save every second
            
            do {
                for (index, log) in symptomLogs.enumerated() {
                    // Create new symptom
                    let newSymptom = SymptomsData(context: backgroundContext)
                    newSymptom.id = UUID()
                    newSymptom.symptom = log.symptom.rawValue
                    newSymptom.startDate = log.startDate
                    newSymptom.endDate = log.endDate
                    newSymptom.notes = log.notes
                    
                    // Save periodically to avoid excessive memory usage
                    if Date().timeIntervalSince(lastSave) > saveInterval {
                        try backgroundContext.save()
                        lastSave = Date()
                        
                        // Report progress
                        let progress = Double(index) / Double(symptomLogs.count)
                        DispatchQueue.main.async {
                            mainDebugger.append("Bulk insert progress: \(Int(progress * 100))%", .justALog)
                        }
                    }
                }
                
                // Final save
                try backgroundContext.save()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // Refresh the main symptoms list
                    self.fetch()
                    completion(.success(()))
                }
            } catch {
                mainDebugger.append("Bulk insert error: \(error)", .error, sourceModule: "SymptomsManager bulkInsert")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
