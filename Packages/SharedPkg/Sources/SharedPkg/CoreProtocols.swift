//
//  CoreProtocols.swift
//  MirrorHR
//
//  Created by Roberto D'Angelo on 04/10/2020.
//

import Combine
import Foundation
import SwiftUI
import PermissionsManager

/// Core communication protocols used throughout the MirrorHR application
/// These protocols establish consistent patterns for event handling,
/// health monitoring, and communication between application components.

/// Protocol for objects that need to subscribe to and handle application events
///
/// Implement this protocol in classes that need to respond to application-wide events
/// from the central event system. The protocol ensures consistent handling of events
/// and proper subscription management.
///
/// Usage example:
/// ```swift
/// class MyEventHandler: EventsSubscriber {
///     var eventSubscriber: AnyCancellable = AnyCancellable({})
///     
///     init() {
///         eventSubscriber = MainEventsPublisher.sink(receiveValue: { [weak self] event in
///             self?.handleEvents(event: event)
///         })
///     }
///     
///     func handleEvents(event: Events) {
///         switch event {
///         case .appDidBecomeActive:
///             // Handle app activation
///         case .heartRateUpdate(let bpm):
///             // Handle heart rate update
///         default:
///             break
///         }
///     }
/// }
/// ```
public protocol EventsSubscriber {
    /// Cancellable subscription to the event publisher
    /// Must be stored to maintain the subscription
    var eventSubscriber: AnyCancellable { get }
    
    /// Method called when an event is received
    /// - Parameter event: The event object containing event type and associated data
    func handleEvents(event: Events)
}

/// Protocol for objects that need to subscribe to and handle HealthKit query events
///
/// Implement this protocol in classes that need to respond to HealthKit data events
/// such as new health readings, query completions, or HealthKit errors.
///
/// Usage example:
/// ```swift
/// class MyHealthKitHandler: HealthKitQueryEventsSubscriber {
///     var eventSubscriber: AnyCancellable = AnyCancellable({})
///     
///     init() {
///         eventSubscriber = healthKitEventsPublisher.sink(receiveValue: { [weak self] event in
///             self?.handleEvents(event: event)
///         })
///     }
///     
///     func handleEvents(event: HealthKitToolsEvents) {
///         switch event {
///         case .healthKitAuthorizationCompleted:
///             // Handle authorization completion
///         case .newHeartRateSample(let sample):
///             // Process new heart rate sample
///         default:
///             break
///         }
///     }
/// }
/// ```
public protocol HealthKitQueryEventsSubscriber {
    /// Cancellable subscription to the HealthKit events publisher
    /// Must be stored to maintain the subscription
    var eventSubscriber: AnyCancellable { get }
    
    /// Method called when a HealthKit event is received
    /// - Parameter event: The HealthKit event object with event type and associated data
    func handleEvents(event: HealthKitToolsEvents)
}

/// Protocol for objects that need to handle communication errors between devices
///
/// Implement this protocol in classes that need to respond to errors in the communication
/// between the iPhone and Apple Watch, such as connectivity issues or message failures.
///
/// Usage example:
/// ```swift
/// class MyCommunicationErrorHandler: CommunicationErrorSubscriber {
///     var communicationErrorSubscriber: AnyCancellable = AnyCancellable({})
///     
///     init() {
///         communicationErrorSubscriber = watchCommunicationErrorsPublisher.sink(receiveValue: { [weak self] error in
///             self?.handleWatchCommunicationError(error)
///         })
///     }
///     
///     func handleWatchCommunicationError(_ error: WatchCommunicationErrors) {
///         switch error {
///         case .connectionFailed:
///             // Handle connection failure
///         case .messageTransferFailed:
///             // Handle message transfer failure
///         }
///     }
/// }
/// ```
public protocol CommunicationErrorSubscriber {
    /// Cancellable subscription to the communication error publisher
    /// Must be stored to maintain the subscription
    var communicationErrorSubscriber: AnyCancellable { get }
    
    /// Method called when a communication error is received
    /// - Parameter error: The communication error object with error type and details
    func handleWatchCommunicationError(_ error: WatchCommunicationErrors)
}

public protocol KeyParametersSubscriber {
    // secure that it can reset to default values
    var parametersSubscriber: AnyCancellable { get }
    func handleUpdateParams()

    // example to put in the init()
    //    eventSubscriber = AnyCancellable({})
    //    eventSubscriber = KeyParametersChanged
    //    .sink(receiveValue: {
    //    handleUpdateParams
    //    printToConsole("params update broadcast received")
    //    })
}

public protocol ResettableToDefaultSetting {
    // secure that it can reset to default values
    var resetToDefaultValues: AnyCancellable { get }
    func reset()

    // example to put in the init()
    //    resetToDefaultValues = AnyCancellable({})
    //    resetToDefaultValues = ResetToDefaultValuesPublisher
    //    .sink(receiveValue: {
    //    self.reset()
    //    printToConsole("ResetToDefaultValuesPublisher event received")
    //    })
}

public protocol LocalStorageProtocol {
    // secure that it can implement basic functions, including the reset of all content based on eraseCommandSubscriber.
    var eraseCommandSubscriber: AnyCancellable { get }
    init(_ storageFileName: String)
    func save(_ jsonString: String)
    func load() -> String
    func remove()
    // example of Publisher:
    /*
     let eraseCommandPublisher = PassthroughSubject<Void, Never>()

     func sendEraseLocalStoragesCommandToAllStorages () {
     printToConsole ("send command to all subscribers")
     eraseCommandPublisher.send()
     }

     Example of subscriber with userdefaults:
     public class LocalStorage: LocalStorageProtocol {
     //take only strings/json
     public var storageFileName : String

     private let userDefaults = UserDefaults.standard
     var eraseCommandSubscriber : AnyCancellable

     required init(storageFileName: String) {
     self.storageFileName = storageFileName
     eraseCommandSubscriber = eraseCommandPublisher
     .sink {
     printToConsole ("eraseCommandSubscriber received for \(storageFileName)")
     UserDefaults.standard.removeObject(forKey: storageFileName)
     }
     }

     private func isKeyPresentInUserDefaults(key: String) -> Bool {
     return userDefaults.object(forKey: key) != nil
     }

     public func save(jsonString: String){
     userDefaults.set(jsonString, forKey: storageFileName)
     }

     public func load() -> String {
     if isKeyPresentInUserDefaults(key: storageFileName) {
     return (userDefaults.string(forKey: storageFileName) ?? "")
     } else {
     return ""
     }
     }

     public func remove() {
     userDefaults.removeObject(forKey: storageFileName)
     }
     }

     */
}

public protocol HealthAuthorizationProtocol: AnyObject {
    var authorized: Bool { get }

    func requestAuthorizationToReadHeartRateData(completion: @escaping (_ status: AuthorizationStatus) -> Void)
}

public protocol ErasableClass {
    // secure that it can erase of all content based on eraseCommandPublisher.
    var eraseCommandSubscriber: AnyCancellable { get }
    // example of Publisher:
    /*
      let eraseCommandPublisher = PassthroughSubject<Void, Never>()
      var eraseCommandSubscriber : AnyCancellable = AnyCancellable({})

     init() {
          eraseCommandSubscriber = eraseCommandPublisher
          .sink {
     printToConsole ("eraseCommandSubscriber received for \(XYZ)")
             custom code
         }
      }
      */
}
