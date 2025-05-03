//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 12/08/22.
//
import Foundation
import Combine
import SwiftUI

public let eraseCommandCombinePublisher = PassthroughSubject<Void, Never>()
public let resetToDefaultValuesCommandPublisher = PassthroughSubject<Void, Never>()

public func sendEraseLocalStoragesCommandToAllStorages() {
    eraseCommandCombinePublisher.send()
}

public func sendResetToDefaultValuesToEverySubscriber() {
    resetToDefaultValuesCommandPublisher.send()
}

public func sendResetEraseToEverySubscriber() {
    eraseCommandCombinePublisher.send()
    resetToDefaultValuesCommandPublisher.send()
    UserDefaults.standard.setValue(true, forKey: "isOnboarding")
}

internal protocol TelemetrySubscriber {
    // secure that it can reset to default values
    var telemetryEventSubscriber: AnyCancellable { get }
    func handleTelemetryEvents(_ event: Telemetries)

    // example to put in the init()
//    public var eventSubscriber = AnyCancellable {}
    //    eventSubscriber = MainEventsPublisher
    //    .sink(receiveValue: { event in
    //    handleEvents(event)
    //    mainDebugger.append("event received")
    //    })
}

internal let telemetryEventsPublisher = PassthroughSubject<Telemetries, Never>()

public func dispatchTelemetryEvent(event: Telemetries) {
    debugLog("Telemetry dispatching \(event) event at \(Date().toStdString())", isImportant: false)
    telemetryEventsPublisher.send(event)
}

// MARK: DataSource Protocol

public protocol DataSourceChangeSubscriber {
    var dataSourceChangeSubscriber: AnyCancellable { get }
    func handleDataSourceChanges(_ dataSource: DataSource)

    // example to put in the init()
//    public var eventSubscriber = AnyCancellable {}
    //    eventSubscriber = dataSourcesChangesPublisher
    //    .sink(receiveValue: { dataSource in
    //    handleDataSourceChanges(dataSource)
    //    mainDebugger.append("New Data Source handled")
    //    })
}

public let dataSourcesChangesPublisher = PassthroughSubject<DataSource, Never>()

public func dispatchDataSourceChange(_ dataSource: DataSource) {
    debugLog("Dispatching Data Source Change with new data source = \(dataSource.rawValue)")
    dataSourcesChangesPublisher.send(dataSource)
}
