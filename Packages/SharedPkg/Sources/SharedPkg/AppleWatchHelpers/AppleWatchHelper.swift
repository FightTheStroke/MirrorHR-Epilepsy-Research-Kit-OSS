//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 03/05/23.
//

import Foundation
import WatchConnectivity

#if os(iOS)
public func isAppleWatchPaired() -> Bool {
    if WCSession.isSupported() {
        let session = WCSession.default
        if session.isPaired {
            return true
        } else {
           return false
        }
    } else {
       return false
    }
}
#endif
