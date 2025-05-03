import Foundation
import OSLog
import SharedPkg
import RoberdanToolBox

/// Error domain for MirrorHR errors
public let MirrorHRErrorDomain = "org.fightthestroke.mirrorhr"

/// A centralized error handling system for the MirrorHR application
/// Provides consistent error handling, reporting, and recovery mechanisms
public final class ErrorHandler {
    // MARK: - Singleton
    
    /// Shared instance of the ErrorHandler
    public static let shared = ErrorHandler()
    
    // MARK: - Properties
    
    /// Logger for error tracking
    private let logger = Logger(subsystem: "org.fightthestroke.mirrorhr", category: "ErrorHandler")
    
    /// Queue for thread-safe operations
    private let queue = DispatchQueue(label: "org.fightthestroke.mirrorhr.errorhandler", qos: .utility)
    
    /// Recent errors storage (limited to avoid memory issues)
    private var recentErrors: [Error] = []
    private let maxRecentErrors = 100
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer to enforce singleton pattern
        setupErrorObservation()
    }
    
    // MARK: - Error Registration
    
    /// Register an error with the error handling system
    /// - Parameters:
    ///   - error: The error to register
    ///   - file: Source file where the error occurred
    ///   - function: Function where the error occurred
    ///   - line: Line number where the error occurred
    ///   - context: Additional context information
    ///   - isFatal: Whether this is a fatal error
    /// - Returns: A unique identifier for this error occurrence
    @discardableResult
    public func register(
        error: Error,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        context: [String: Any]? = nil,
        isFatal: Bool = false
    ) -> UUID {
        let errorID = UUID()
        
        // Create standardized error information
        let errorInfo: [String: Any] = [
            "id": errorID.uuidString,
            "timestamp": Date(),
            "errorDomain": (error as NSError).domain,
            "errorCode": (error as NSError).code,
            "errorDescription": error.localizedDescription,
            "file": file,
            "function": function,
            "line": line,
            "context": context ?? [:],
            "isFatal": isFatal
        ]
        
        // Log the error
        logger.error("Error[\(errorID.uuidString)]: \(error.localizedDescription, privacy: .public) in \(function, privacy: .public) line \(line, privacy: .public)")
        
        // Store in recent errors
        queue.async {
            self.storeRecentError(error)
        }
        
        // Log to debug system
        MainDebugger.shared.append("ERROR: \(error.localizedDescription) [\(file):\(line)]", .error)
        
        // Dispatch telemetry event
        // TODO: Implement error publishing
        // EventsDispatcher.shared.publish(eventName: HandledEvents.errorOccurred.rawValue, payload: errorInfo)
        
        // Handle fatal errors
        if isFatal {
            self.handleFatalError(error, errorID: errorID, context: context)
        }
        
        return errorID
    }
    
    // MARK: - Error Recovery
    
    /// Provides recovery options for a given error
    /// - Parameter error: The error to analyze
    /// - Returns: Array of recovery options if available
    public func recoveryOptionsFor(error: Error) -> [ErrorRecoveryOption] {
        let nsError = error as NSError
        
        // Determine error type and provide appropriate recovery options
        switch nsError.domain {
        case NSCocoaErrorDomain:
            return handleCocoaError(nsError)
            
        case "CoreDataError":
            return handleCoreDataError(nsError)
            
        case "NetworkError":
            return handleNetworkError(nsError)
            
        case "PermissionError":
            return handlePermissionError(nsError)
            
        case "AVFoundationError":
            return handleAVError(nsError)
            
        case "HealthKitError":
            return handleHealthKitError(nsError)
            
        default:
            // Default recovery options
            return [
                ErrorRecoveryOption(title: "Try Again", action: .retry),
                ErrorRecoveryOption(title: "Cancel", action: .cancel)
            ]
        }
    }
    
    // MARK: - Domain-Specific Error Handling
    
    private func handleCocoaError(_ error: NSError) -> [ErrorRecoveryOption] {
        switch error.code {
        case NSFileNoSuchFileError:
            return [
                ErrorRecoveryOption(title: "Create File", action: .custom("createFile")),
                ErrorRecoveryOption(title: "Choose Different File", action: .custom("chooseFile")),
                ErrorRecoveryOption(title: "Cancel", action: .cancel)
            ]
            
        case NSFileWriteOutOfSpaceError:
            return [
                ErrorRecoveryOption(title: "Free Up Space", action: .custom("freeSpace")),
                ErrorRecoveryOption(title: "Cancel", action: .cancel)
            ]
            
        default:
            return [
                ErrorRecoveryOption(title: "Try Again", action: .retry),
                ErrorRecoveryOption(title: "Cancel", action: .cancel)
            ]
        }
    }
    
    private func handleCoreDataError(_ error: NSError) -> [ErrorRecoveryOption] {
        return [
            ErrorRecoveryOption(title: "Restart Database", action: .custom("restartDatabase")),
            ErrorRecoveryOption(title: "Restore from Backup", action: .custom("restoreBackup")),
            ErrorRecoveryOption(title: "Cancel", action: .cancel)
        ]
    }
    
    private func handleNetworkError(_ error: NSError) -> [ErrorRecoveryOption] {
        return [
            ErrorRecoveryOption(title: "Try Again", action: .retry),
            ErrorRecoveryOption(title: "Use Offline Mode", action: .custom("offlineMode")),
            ErrorRecoveryOption(title: "Cancel", action: .cancel)
        ]
    }
    
    private func handlePermissionError(_ error: NSError) -> [ErrorRecoveryOption] {
        return [
            ErrorRecoveryOption(title: "Open Settings", action: .custom("openSettings")),
            ErrorRecoveryOption(title: "Continue without Permission", action: .custom("continueWithoutPermission")),
            ErrorRecoveryOption(title: "Cancel", action: .cancel)
        ]
    }
    
    private func handleAVError(_ error: NSError) -> [ErrorRecoveryOption] {
        return [
            ErrorRecoveryOption(title: "Try Again", action: .retry),
            ErrorRecoveryOption(title: "Use Alternate Method", action: .custom("alternateMethod")),
            ErrorRecoveryOption(title: "Cancel", action: .cancel)
        ]
    }
    
    private func handleHealthKitError(_ error: NSError) -> [ErrorRecoveryOption] {
        return [
            ErrorRecoveryOption(title: "Request Permissions", action: .custom("requestHealthKitPermissions")),
            ErrorRecoveryOption(title: "Continue without HealthKit", action: .custom("continueWithoutHealthKit")),
            ErrorRecoveryOption(title: "Cancel", action: .cancel)
        ]
    }
    
    // MARK: - Fatal Error Handling
    
    private func handleFatalError(_ error: Error, errorID: UUID, context: [String: Any]?) {
        // Log the fatal error
        logger.critical("FATAL ERROR[\(errorID.uuidString)]: \(error.localizedDescription, privacy: .public)")
        
        // Save application state
        saveApplicationState()
        
        // Notify user
        NotificationCenter.default.post(
            name: Notification.Name("MirrorHR.FatalErrorOccurred"),
            object: nil,
            userInfo: ["error": error, "errorID": errorID, "context": context ?? [:]]
        )
        
        // Allow app to continue but in a recovery state
        enterRecoveryMode()
    }
    
    private func saveApplicationState() {
        // Save critical user data
        queue.async {
            // Implementation for saving app state
            // This would coordinate with managers to save state
        }
    }
    
    private func enterRecoveryMode() {
        // Notify system to enter recovery mode
        NotificationCenter.default.post(name: Notification.Name("MirrorHR.EnterRecoveryMode"), object: nil)
    }
    
    // MARK: - Error History Management
    
    private func storeRecentError(_ error: Error) {
        queue.async {
            // Add to recent errors, enforcing size limit
            self.recentErrors.append(error)
            if self.recentErrors.count > self.maxRecentErrors {
                self.recentErrors.removeFirst()
            }
        }
    }
    
    /// Get recent errors for diagnostics
    /// - Returns: Array of recent errors
    public func getRecentErrors() -> [Error] {
        var result: [Error] = []
        queue.sync {
            result = self.recentErrors
        }
        return result
    }
    
    /// Clear the error history
    public func clearErrorHistory() {
        queue.async {
            self.recentErrors.removeAll()
        }
    }
    
    // MARK: - Observation Setup
    
    private func setupErrorObservation() {
        // Subscribe to uncaught exception notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUncaughtException),
            name: NSNotification.Name("NSApplicationDidCatchExceptionNotification"),
            object: nil
        )
    }
    
    @objc private func handleUncaughtException(notification: Notification) {
        if let exception = notification.userInfo?["NSException"] as? NSException {
            let errorMessage = "Uncaught exception: \(exception.name.rawValue) - \(exception.reason ?? "unknown reason")"
            
            // Create an NSError from the exception
            let error = NSError(
                domain: MirrorHRErrorDomain,
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: errorMessage,
                    "exception": exception,
                    "callStackSymbols": exception.callStackSymbols
                ]
            )
            
            // Register the error
            register(error: error, context: ["uncaughtException": true], isFatal: true)
        }
    }
}

// MARK: - Supporting Types

/// Represents an action that can be taken to recover from an error
public enum ErrorRecoveryAction {
    case retry
    case cancel
    case custom(String)
}

/// Represents a recovery option that can be presented to the user
public struct ErrorRecoveryOption {
    /// The title of the recovery option
    public let title: String
    
    /// The action to take if this option is selected
    public let action: ErrorRecoveryAction
    
    /// Optional description of what this option will do
    public let description: String?
    
    public init(title: String, action: ErrorRecoveryAction, description: String? = nil) {
        self.title = title
        self.action = action
        self.description = description
    }
}

// MARK: - Convenience Extensions

/// Extension to Error to provide easy registration with the ErrorHandler
public extension Error {
    /// Register this error with the central error handling system
    /// - Parameters:
    ///   - file: Source file where the error occurred
    ///   - function: Function where the error occurred
    ///   - line: Line number where the error occurred
    ///   - context: Additional context information
    ///   - isFatal: Whether this is a fatal error
    /// - Returns: A unique identifier for this error occurrence
    func register(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        context: [String: Any]? = nil,
        isFatal: Bool = false
    ) -> UUID {
        return ErrorHandler.shared.register(
            error: self,
            file: file,
            function: function,
            line: line,
            context: context,
            isFatal: isFatal
        )
    }
} 