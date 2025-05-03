//
//  BackupManager.swift
//
//
//  Created by Roberto D'Angelo on 06/05/24.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import SharedPkg
import MirrorHRTelemetryPackage
import CoreData
import OSLog
import CryptoKit

/// Manages backup and restore operations for application data
public class BackupManager {
    
    /// Shared logger instance for the backup manager
    private static let logger = Logger(subsystem: "MirrorHR", category: "BackupManager")
    
    // MARK: - Error Types
    
    /// Error types that can occur during backup and restore operations
    public enum BackupError: Error, LocalizedError {
        case serializationFailed
        case jsonEncodingFailed
        case jsonDecodingFailed
        case dataCorruption
        case checksumMismatch(String)
        case missingData(String)
        case validationFailed(String)
        case incompatibleVersion(required: String, found: String)
        case storageError(String)
        case unknown(Error)
        
        public var errorDescription: String? {
            switch self {
            case .serializationFailed:
                return "Failed to serialize backup data"
            case .jsonEncodingFailed:
                return "Failed to encode data to JSON"
            case .jsonDecodingFailed:
                return "Failed to decode JSON data"
            case .dataCorruption:
                return "Data corruption detected"
            case .checksumMismatch(let component):
                return "Checksum mismatch for \(component)"
            case .missingData(let field):
                return "Required data missing: \(field)"
            case .validationFailed(let reason):
                return "Validation failed: \(reason)"
            case .incompatibleVersion(let required, let found):
                return "Incompatible backup version (required: \(required), found: \(found))"
            case .storageError(let reason):
                return "Storage error: \(reason)"
            case .unknown(let error):
                return "Unknown error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Backup Version
    
    /// Current backup format version
    public static let currentBackupVersion = "1.1"
    
    /// Minimum supported backup version for restore
    public static let minimumSupportedVersion = "1.0"
    
    // MARK: - JSON Backup and Restore
    
    /// Creates a backup of application data
    /// - Parameters:
    ///   - completion: Callback with success (URL where backup is saved) or failure
    ///   - progressUpdate: Optional callback to report progress percentage
    public static func createBackup(
        completion: @escaping (Result<URL, Error>) -> Void,
        progressUpdate: ((Double) -> Void)? = nil
    ) {
        progressUpdate?(0.0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                do {
                    // Ensure consistent database state before backup
                    try PersistenceController.shared.container.viewContext.save()
                    
                    progressUpdate?(5.0)
                    
                    // Create backup dictionary with metadata
                    var backupData = [String: Any]()
                    
                    // Add metadata
                    backupData["backupVersion"] = currentBackupVersion
                    backupData["timestamp"] = Date().timeIntervalSince1970
                    backupData["appVersion"] = appVersion
                    
                    let totalComponents = 7
                    var currentComponent = 0
                    
                    // Helper function to compute SHA256 hash for validation
                    func computeChecksum(for jsonString: String) -> String {
                        let data = Data(jsonString.utf8)
                        let hash = SHA256.hash(data: data)
                        return hash.compactMap { String(format: "%02x", $0) }.joined()
                    }
                    
                    // Process each component with proper error handling
                    func processComponent(
                        name: String,
                        manager: Any,
                        jsonProvider: () throws -> String
                    ) {
                        do {
                            // Get JSON representation
                            let jsonString = try jsonProvider()
                            
                            // Add content and checksum
                            backupData[name] = jsonString
                            backupData["\(name)_checksum"] = computeChecksum(for: jsonString)
                            
                            // Update progress
                            currentComponent += 1
                            progressUpdate?(5.0 + (Double(currentComponent) / Double(totalComponents)) * 80.0)
                            
                            logger.debug("Successfully backed up \(name)")
                        } catch {
                            logger.error("Error backing up \(name): \(error.localizedDescription)")
                            // Continue with other components - we'll include what we can
                        }
                    }
                    
                    // Back up each component
                    processComponent(name: "DataSourceManager", manager: DataSourceManager.shared) {
                        DataSourceManager.shared.jsonString() ?? ""
                    }
                    
                    processComponent(name: "SoundOptions", manager: SoundOptions.shared) {
                        SoundOptions.shared.jsonString() ?? ""
                    }
                    
                    processComponent(name: "CareGiversManager", manager: CareGiversManager.shared) {
                        CareGiversManager.shared.jsonString() ?? ""
                    }
                    
                    processComponent(name: "ProfileSettings", manager: ProfileGenericSettings.shared) {
                        ProfileGenericSettings.shared.jsonString() ?? ""
                    }
                    
                    processComponent(name: "KeyFlowThresholds", manager: KeyFlowThresholds.shared) {
                        KeyFlowThresholds.shared.jsonString()
                    }
                    
                    processComponent(name: "TherapyManager", manager: TherapyManager.shared) {
                        try TherapyManager.shared.jsonString()
                    }
                    
                    processComponent(name: "SymptomsManager", manager: SymptomsManager.shared) {
                        try SymptomsManager.shared.jsonString()
                    }
                    
                    progressUpdate?(90.0)
                    
                    // Validate backup data
                    if !JSONSerialization.isValidJSONObject(backupData) {
                        throw BackupError.serializationFailed
                    }
                    
                    // Generate final JSON
                    let jsonData = try JSONSerialization.data(withJSONObject: backupData, options: [.prettyPrinted, .sortedKeys])
                    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                        throw BackupError.jsonEncodingFailed
                    }
                    
                    progressUpdate?(95.0)
                    
                    // Save the backup to a file
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
                    let fileName = "MirrorHR_Backup_\(dateFormatter.string(from: Date())).json"
                    
                    let result = try saveBackupToFileSync(jsonString: jsonString, fileName: fileName)
                    
                    progressUpdate?(100.0)
                    
                    logger.info("Backup completed successfully")
                    
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch let backupError as BackupError {
                    logger.error("Backup failed with error: \(backupError.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(backupError))
                    }
                } catch {
                    logger.error("Backup failed with error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(BackupError.unknown(error)))
                    }
                }
            }
        }
    }
    
    /// Restores application data from a backup file
    /// - Parameters:
    ///   - url: The URL of the backup file
    ///   - completion: Callback with success or failure
    ///   - progressUpdate: Optional callback to report progress percentage
    public static func restoreBackup(
        from url: URL,
        completion: @escaping (Result<Void, Error>) -> Void,
        progressUpdate: ((Double) -> Void)? = nil
    ) {
        progressUpdate?(0.0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                do {
                    // Read data from URL
                    let jsonData = try Data(contentsOf: url)
                    logger.info("Loading backup from \(url.lastPathComponent)")
                    
                    // Parse JSON data
                    let backupData = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
                    guard let backupData = backupData else {
                        throw BackupError.jsonDecodingFailed
                    }
                    
                    progressUpdate?(10.0)
                    
                    // Validate backup version
                    if let version = backupData["backupVersion"] as? String {
                        logger.info("Restoring from backup version: \(version)")
                        
                        // Check if version is supported
                        if !isVersionSupported(version) {
                            throw BackupError.incompatibleVersion(
                                required: minimumSupportedVersion,
                                found: version
                            )
                        }
                    } else {
                        logger.warning("No version information in backup, assuming legacy format")
                    }
                    
                    // Helper function to verify checksums
                    func verifyChecksum(for component: String) -> Bool {
                        guard let content = backupData[component] as? String,
                              let storedChecksum = backupData["\(component)_checksum"] as? String else {
                            return true // No checksum to verify, consider it valid
                        }
                        
                        let data = Data(content.utf8)
                        let hash = SHA256.hash(data: data)
                        let computedChecksum = hash.compactMap { String(format: "%02x", $0) }.joined()
                        
                        return computedChecksum == storedChecksum
                    }
                    
                    // Process and restore components
                    let totalComponents = 7
                    var currentComponent = 0
                    var restoredComponents = [String]()
                    
                    // Helper to safely restore a component
                    func restoreComponent(
                        name: String,
                        requiresChecksum: Bool = false,
                        restoreAction: (String) throws -> Void
                    ) {
                        guard let componentData = backupData[name] as? String else {
                            logger.warning("\(name) data missing or invalid in backup")
                            return
                        }

                        // Verify checksum if needed
                        if requiresChecksum && !verifyChecksum(for: name) {
                            logger.error("Checksum verification failed for \(name)")
                            return
                        }

                        // Try restoring the component
                        do {
                            try restoreAction(componentData)
                            restoredComponents.append(name)
                            logger.debug("Successfully restored \(name)")
                        } catch {
                            logger.error("Failed to restore \(name): \(error.localizedDescription)")
                        }

                        // Update progress
                        currentComponent += 1
                        progressUpdate?(10.0 + (Double(currentComponent) / Double(totalComponents)) * 80.0)
                    }
                    
                    // Perform restoration of each component
                    restoreComponent(name: "DataSourceManager") { json in
                        DataSourceManager.shared.loadFromJson(jsonString: json)
                    }
                    
                    restoreComponent(name: "SoundOptions") { json in
                        SoundOptions.shared.loadFromJson(jsonString: json)
                    }
                    
                    restoreComponent(name: "CareGiversManager") { json in
                        CareGiversManager.shared.loadFromJson(jsonString: json)
                    }
                    
                    restoreComponent(name: "KeyFlowThresholds") { json in
                        KeyFlowThresholds.shared.loadFromJson(jsonString: json)
                    }
                    
                    restoreComponent(name: "ProfileSettings") { json in
                        try ProfileGenericSettings.shared.loadFromJson(jsonString: json)
                    }
                    
                    restoreComponent(name: "TherapyManager") { json in
                        try TherapyManager.shared.loadFromJson(jsonString: json)
                    }
                    
                    restoreComponent(name: "SymptomsManager") { json in
                        try SymptomsManager.shared.loadFromJson(jsonString: json)
                    }
                    
                    // Save Core Data changes
                    try PersistenceController.shared.container.viewContext.save()
                    
                    progressUpdate?(100.0)
                    
                    // Determine success or partial success
                    if restoredComponents.count == totalComponents {
                        logger.info("Restore completed successfully for all components")
                    } else {
                        logger.warning("Partially restored data: \(restoredComponents.joined(separator: ", "))")
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch let restoreError as BackupError {
                    logger.error("Restore failed: \(restoreError.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(restoreError))
                    }
                } catch {
                    logger.error("Restore failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(BackupError.unknown(error)))
                    }
                }
            }
        }
    }
    
    /// Checks if a backup version is supported
    /// - Parameter version: The version string to check
    /// - Returns: Whether the version is supported
    private static func isVersionSupported(_ version: String) -> Bool {
        // Simple version comparison - could be enhanced for more complex version requirements
        if version == minimumSupportedVersion || version == currentBackupVersion {
            return true
        }
        
        // For more complex version comparison:
        // let components = version.split(separator: ".")
        // if components.count >= 2 {
        //    // Compare major/minor versions
        // }
        
        return false
    }
    
    // MARK: - File Operations
    
    /// Saves a backup to a file synchronously
    /// - Parameters:
    ///   - jsonString: The backup data as JSON
    ///   - fileName: Optional file name (defaults to timestamped name)
    /// - Returns: The URL where the backup was saved
    /// - Throws: Error if saving fails
    private static func saveBackupToFileSync(
        jsonString: String,
        fileName: String? = nil
    ) throws -> URL {
        let fileManager = FileManager.default
        
        // Get documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw BackupError.storageError("Could not access documents directory")
        }
        
        // Create backups directory if needed
        let backupsDirectory = documentsDirectory.appendingPathComponent("Backups", isDirectory: true)
        
        if !fileManager.fileExists(atPath: backupsDirectory.path) {
            try fileManager.createDirectory(at: backupsDirectory, withIntermediateDirectories: true)
        }
        
        // Create file name with timestamp if not provided
        let actualFileName: String
        if let fileName = fileName {
            actualFileName = fileName
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
            actualFileName = "MirrorHR_Backup_\(dateFormatter.string(from: Date())).json"
        }
        
        // Create file URL
        let fileURL = backupsDirectory.appendingPathComponent(actualFileName)
        
        // Write data to file
        let data = Data(jsonString.utf8)
        try data.write(to: fileURL)
        
        logger.info("Backup saved to file: \(fileURL.lastPathComponent)")
        
        return fileURL
    }
    
    /// Loads a backup from a file
    /// - Parameters:
    ///   - url: The URL of the backup file
    ///   - completion: Callback with JSON string or error
    public static func loadBackupFromFile(
        url: URL,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Read file data
                let data = try Data(contentsOf: url)
                
                // Convert to string
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    throw BackupError.jsonDecodingFailed
                }
                
                logger.info("Backup loaded from file: \(url.lastPathComponent)")
                
                DispatchQueue.main.async {
                    completion(.success(jsonString))
                }
            } catch {
                logger.error("Failed to load backup from file: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Gets a list of available backup files
    /// - Parameter completion: Callback with array of file URLs
    public static func getAvailableBackups(completion: @escaping (Result<[URL], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fileManager = FileManager.default
                
                // Get documents directory
                guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    throw BackupError.storageError("Could not access documents directory")
                }
                
                // Check backups directory
                let backupsDirectory = documentsDirectory.appendingPathComponent("Backups", isDirectory: true)
                
                if !fileManager.fileExists(atPath: backupsDirectory.path) {
                    // No backups directory yet
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                
                // List files in directory
                let fileURLs = try fileManager.contentsOfDirectory(
                    at: backupsDirectory,
                    includingPropertiesForKeys: [.contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                )
                
                // Filter for JSON files
                let backupFiles = fileURLs.filter { $0.pathExtension.lowercased() == "json" }
                
                // Sort by modification date (newest first)
                let sortedFiles = try backupFiles.sorted { (url1, url2) -> Bool in
                    let date1 = try url1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
                    let date2 = try url2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
                    return date1 > date2
                }
                
                logger.debug("Found \(sortedFiles.count) backup files")
                
                DispatchQueue.main.async {
                    completion(.success(sortedFiles))
                }
            } catch {
                logger.error("Failed to list backup files: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
