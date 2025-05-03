//
//  StreamingProtocols.swift
//
//
//  Created by Roberto D’Angelo on 12/08/22.
//

import Foundation
import Combine

public let streamingEventsPublisher = PassthroughSubject<StreamingMessage, Never>()

public func dispatchStreamingMessage(_ message: StreamingMessage) {
    streamingEventsPublisher.send(message)
}

public protocol StreamingSubscriber {
    // secure that it can reset to default values
    var streamingMessagesSubscriber: AnyCancellable { get }
    func handleStreamingMessage(_ message: StreamingMessage)

//    public var eventSubscriber = AnyCancellable {}
    // example to put in the init()
    //    streamingMessagesSubscriber = streamingEventsPublisher
    //    .sink(receiveValue: { event in
    //    handleEvents(event)
    //    mainDebugger.append("event received")
    //    })
}
