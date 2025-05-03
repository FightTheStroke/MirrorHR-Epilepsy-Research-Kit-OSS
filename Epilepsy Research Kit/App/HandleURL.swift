//
//  HandleURL.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 27/05/23.
//  Copyright © 2023 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import MirrorHRKit
import SwiftUI
import MirrorHRTelemetryPackage
import Stripe

// Handle URL like MirrorHR://addCareGiver and MirrorHR://callHelp
func handleURL(_ url: URL) {
    let stripeHandled = StripeAPI.handleURLCallback(with: url)
    if (stripeHandled) {
        return
    }
    
    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
          let host = components.host else {
        print("Invalid URL or host missing")
        return
    }
    
    if host == addCaregiverHost && components.queryItems != nil {
        if let id = components.queryItems?.first(where: { $0.name == "ID" })?.value {
            if UUID(uuidString: id) != nil {
                DispatchQueue.main.async {
                    let showSheet: SheetViewController = .shared
                    showSheet.reset()
                    showSheet.sheetContentView = AnyView(AddCareGiverView(caregiversManager: .shared, uuid: id, uuidFromURL: true))
                    showSheet.sheetVisible = true
                }
            }
        }
    }
    
    if host == addPatientHost && components.queryItems != nil {
        if let id = components.queryItems?.first(where: { $0.name == "ID" })?.value {
            if UUID(uuidString: id) != nil {
                DispatchQueue.main.async {
                    let showSheet: SheetViewController = .shared
                    showSheet.reset()
                    showSheet.sheetContentView = AnyView(AddRemotePatientView(caregiversManager: .shared, uuid: id, uuidFromURL: true))
                    showSheet.sheetVisible = true
                }
            }
        }
    }
    
    // this is when the button on the Widget is Pressed and send MirroHR://callHelp
    if host == ask4HelpHost {
        ask4HelpFunction()
    }
    
    if host == fastHelpHost {
        // This will give you the symptom value passed in the URL
        guard let value = url.query, let symptom = HandledSymptomsEvents(rawValue: value) else {
            return
        }
        symptom.quickCommandAction()
    }
}
