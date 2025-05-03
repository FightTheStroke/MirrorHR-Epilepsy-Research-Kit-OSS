//
//  PersistenceCoreData.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 08/02/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import CoreData
import SharedPkg
import OSLog

/// Manages Core Data persistent stores and contexts for the application
public struct PersistenceController {
    /// Shared singleton instance
    public static let shared = PersistenceController()
    
    /// Logger for persistence operations
    private let logger = Logger(subsystem: "MirrorHRKit", category: "PersistenceController")

    /// Preview controller for SwiftUI previews and testing
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        for _ in 0 ..< 10 {
            let newSymptom = SymptomsData(context: viewContext)
            newSymptom.startDate = Date()
            newSymptom.notes = "Symptom Test"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            result.logger.error("Preview data save error: \(nsError.localizedDescription)")
            // Continue without crashing in preview mode
        }
        return result
    }()

    /// Persistent container for Core Data operations
    public let container: NSPersistentContainer
    
    /// Initializes the persistence controller
    /// - Parameter inMemory: Whether to use an in-memory store (for testing/previews)
    init(inMemory: Bool = false) {
        // Use the default CoreData model included in the application bundle
        container = NSPersistentContainer(name: "SessionCoreDataModel")
        
        // Enable persistent history tracking for change tracking
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        // Configure in-memory store if needed
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Load persistent stores with proper error handling
        container.loadPersistentStores { [self] _, error in
            if let error = error as NSError? {
                self.logger.error("Core Data store failed to load: \(error.localizedDescription)")
                
                // Attempt recovery based on error type
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    case NSPersistentStoreIncompatibleVersionHashError,
                         NSMigrationMissingSourceModelError,
                         NSMigrationError:
                        // Migration errors
                        self.handleMigrationError(error)
                    case NSFileReadCorruptFileError,
                         NSPersistentStoreIncompleteSaveError,
                         NSPersistentStoreInvalidTypeError:
                        // Corruption errors
                        self.handleCorruptStoreError(error)
                    case NSFileReadNoSuchFileError:
                        // Missing file errors
                        self.handleMissingStoreError()
                    default:
                        // Other Core Data errors
                        self.notifyUserOfDatabaseIssue(error)
                    }
                } else {
                    self.notifyUserOfDatabaseIssue(error)
                }
            } else {
                self.logger.info("Core Data stores loaded successfully")
            }
        }
        
        // Configure merge policies and other container settings
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// Creates a background context for performing operations off the main thread
    /// - Returns: A new managed object context on a background queue
    public func createBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// Handles migration errors by attempting recovery
    /// - Parameter error: The NSError from Core Data
    private func handleMigrationError(_ error: NSError) {
        logger.warning("Core Data migration error: \(error.localizedDescription)")
        
        // Could implement progressive migration here for complex model changes
    }
    
    /// Handles corrupt store errors by attempting to recover or recreate the store
    /// - Parameter error: The NSError from Core Data
    private func handleCorruptStoreError(_ error: NSError) {
        logger.warning("Core Data store corruption detected: \(error.localizedDescription)")
        
        // Attempt recovery by recreating the store
        // In a production app, we would want to try backing up corrupted data first
        
        // Remove the existing store
        if let storeURL = container.persistentStoreDescriptions.first?.url,
           let storeType = container.persistentStoreDescriptions.first?.type {
            
            do {
                // Attempt to remove the corrupt store
                try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: storeType, options: nil)
                
                // Try to add a fresh store
                try container.persistentStoreCoordinator.addPersistentStore(ofType: storeType, configurationName: nil, at: storeURL, options: nil)
                
                logger.info("Successfully recreated Core Data store after corruption")
            } catch {
                logger.error("Failed to recover from corrupt store: \(error.localizedDescription)")
                notifyUserOfDatabaseIssue(error as NSError)
            }
        } else {
            notifyUserOfDatabaseIssue(error)
        }
    }
    
    /// Handles missing store errors by creating a new store
    private func handleMissingStoreError() {
        logger.warning("Core Data store file not found, creating new store")
        
        // This will happen automatically when we attempt to save, but we can
        // be more explicit about the process and error handling
        
        if let storeURL = container.persistentStoreDescriptions.first?.url,
           let storeType = container.persistentStoreDescriptions.first?.type {
            
            do {
                // Try to add a fresh store
                try container.persistentStoreCoordinator.addPersistentStore(ofType: storeType, configurationName: nil, at: storeURL, options: nil)
                
                logger.info("Successfully created new Core Data store")
                
                // Initialize with default data if needed
                initializeDefaultData()
            } catch {
                logger.error("Failed to create new store: \(error.localizedDescription)")
                notifyUserOfDatabaseIssue(error as NSError)
            }
        }
    }
    
    /// Initializes the database with default data for a new installation
    private func initializeDefaultData() {
        // Add default data needed for the app to function
        let context = container.viewContext
        
        // Example: Add default categories, etc.
        
        do {
            try context.save()
        } catch {
            logger.error("Failed to save default data: \(error.localizedDescription)")
        }
    }
    
    /// Notifies the user of database issues and provides options
    /// - Parameter error: The error that occurred
    private func notifyUserOfDatabaseIssue(_ error: NSError) {
        logger.error("Database issue needs user attention: \(error.localizedDescription)")
    }
}
