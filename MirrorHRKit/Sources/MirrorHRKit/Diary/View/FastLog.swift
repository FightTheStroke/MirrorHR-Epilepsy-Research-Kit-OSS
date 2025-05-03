//
//  FastLog.swift
//
//
//  Created by Roberto D’Angelo on 27/03/22.
//

import Foundation
import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

extension HandledSymptomsEvents { // Extension handling quick commands in the diary view
    
    // used in fastLogs views. Max SymptomsManager.maxTopLoggedSymptoms symptoms only, usually 6
    public static let quickCommands: [HandledSymptomsEvents] = [
        .seizure, .videoSeizureLog, .absence, .medicationForgotten, .medicationTaken, .videoLog
    ]
    
    public var quickCommandAction: () -> Void {
        let sheetViewController: SheetViewController = .shared
        switch self {
        case .videoLog: return {
            let videoPicker = VideoPicker(videoType: .log, onDismiss: { SheetViewController.shared.sheetVisible = false })
            sheetViewController.reset()
            sheetViewController.navigationTitle = keySettingsNavigationTitleMsg
            sheetViewController.okAction = { videoPicker.stopCapture() }
            sheetViewController.sheetContentView = AnyView(videoPickerView(videoPicker: videoPicker))
            sheetViewController.cancelActionText = cancelActionMsg
            sheetViewController.cancelActionImage = ""
            sheetViewController.okActionImage = ""
            sheetViewController.okActionText = saveBtnMsg
            sheetViewController.dismissAction = { videoPicker.stopCapture() }
            sheetViewController.sheetVisible = true
        }
        case .videoSeizureLog: return {
            let videoPicker = VideoPicker(videoType: .seizure, onDismiss: { SheetViewController.shared.sheetVisible = false })
            sheetViewController.reset()
            sheetViewController.navigationTitle = keySettingsNavigationTitleMsg
            sheetViewController.okAction = { videoPicker.stopCapture() }
            sheetViewController.sheetContentView = AnyView(videoPickerView(videoPicker: videoPicker))
            sheetViewController.cancelActionText = cancelActionMsg
            sheetViewController.cancelActionImage = ""
            sheetViewController.okActionImage = ""
            sheetViewController.okActionText = saveBtnMsg
            sheetViewController.dismissAction = { videoPicker.stopCapture() }
            sheetViewController.sheetVisible = true
        }
        default: 
            return {
                SymptomsManager.shared.appendSymptomLog(SymptomLog(self))
            }
        }
    }
    
    func videoPickerView(videoPicker: VideoPicker) -> some View {
        ZStack {
            videoPicker
                .overlay(VideoControlButtonsView(videoPicker: videoPicker), alignment: .top)
        }
    }
}

extension View {
    @ViewBuilder
    public func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) } else { self }
    }
}
