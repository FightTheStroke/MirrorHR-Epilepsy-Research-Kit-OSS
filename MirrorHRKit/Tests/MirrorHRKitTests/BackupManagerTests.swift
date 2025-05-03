////
////  BackupManagerTests.swift
////  
////
////  Created by Roberto D’Angelo on 15/06/24.
////
//import XCTest
//import MirrorHRKit
//
//class BackupManagerTests: XCTestCase {
//    var backupURL: URL! = FileManager.default.temporaryDirectory.appendingPathComponent("backup.zip")
//    var restoreURL: URL! = FileManager.default.temporaryDirectory.appendingPathComponent("restore")
//    
//    override init() {
//        if FileManager.default.fileExists(atPath: backupURL.path) {
//            do {
//                try FileManager.default.removeItem(at: backupURL)
//            } catch {
//                XCTFail("Failed to clean up test environment: \(error)")
//            }
//        }
//        if FileManager.default.fileExists(atPath: restoreURL.path) {
//            do {
//                try FileManager.default.removeItem(at: restoreURL)
//            } catch {
//                XCTFail("Failed to clean up test environment: \(error)")
//            }
//        }
//    }
//    
//    func testBackupAndRestore() throws {
//        // Perform the backup
////        try BackupManager.createBackup(to: backupURL)
////        
////        // Assert that the backup file exists
////        XCTAssertTrue(FileManager.default.fileExists(atPath: backupURL.path), "Backup file should exist")
////        
////        // Perform the restore
////        try BackupManager.restoreBackup(from: backupURL)
////        
////        // Assert that the restore was successful
////        // This can be app-specific. For example, you might check if the restored data matches the original data.
////        
////        // Check JSON restoration
////        let jsonRestoreURL = restoreURL.appendingPathComponent("backup.json")
////        XCTAssertTrue(FileManager.default.fileExists(atPath: jsonRestoreURL.path), "JSON restore file should exist")
////        
////        // Check Core Data restoration
////        let coreDataRestoreURL = restoreURL.appendingPathComponent("backup.sqlite")
////        XCTAssertTrue(FileManager.default.fileExists(atPath: coreDataRestoreURL.path), "Core Data restore file should exist")
//    }
//}
