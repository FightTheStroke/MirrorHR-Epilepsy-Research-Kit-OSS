//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import Foundation
import SharedPkg

internal extension LocalStreamingManager {
    enum StreamingStorageKeys: StorageKey {
        case isEnabled
        case isServer
        case isClient
        
        var value: String {
            switch self {
            case .isEnabled:
                return "StreamingManager.isEnabled"
            case .isServer:
                return "StreamingManager.isServer"
            case .isClient:
                return "StreamingManager.isClient"
            }
        }
    }
}
