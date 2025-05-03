//
//  StreamingMessageExtension.swift
//
//
//  Created by Roberto D’Angelo on 18/05/24.
//

import Foundation
import SharedPkg
import MultipeerConnectivity

public extension StreamingMessage {
    var isUser: Bool {
        return displayName == UIDevice.current.name
    }
}
