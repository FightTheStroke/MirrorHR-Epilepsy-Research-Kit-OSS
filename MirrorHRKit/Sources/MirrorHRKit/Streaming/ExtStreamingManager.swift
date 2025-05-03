//
//  StreamingMessage.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 21/08/22.
//

import Foundation
import SharedPkg

extension StreamingMessage {
    public var bpmFromStreaming: BPMFromWatch? {
        if messageType == .bpm {
            var bpm: BPMFromWatch = BPMFromWatch()
            bpm.bpm = valueInt ?? 0
            return bpm
        } else {
            return nil
        }
    }
}
