//
//  WatchLog.swift
//  it shows logs from MainDebugger.shared on Apple Watch
//
//  Created by Roberto D’Angelo on 22/12/20.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)

public struct WatchLogView: View {
    @ObservedObject var myDebugger = MainDebugger.shared

    public init() {
        // on the watch logs are always on
        myDebugger.turnOnOff(true)
    }

    public var body: some View {
        List(myDebugger.debugLogs, id: \.self) { logs in
            LogsRow(logs: logs)
        }
    }
}

@available(OSX 10.15, *)
public struct LogsRow: View {
    var logs: DebugLog

    public var body: some View {
        HStack {
            VStack {
                Text("\(logs.debugTimeStamp.toTimeStampFormatter())")
                Text("\(logs.msgType.description)")
            }
            Text("\(logs.debugString)")
        }
    }
}
