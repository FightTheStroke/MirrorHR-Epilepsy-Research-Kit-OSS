//
//  GoToWebFunc.swift
//  
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import SwiftUI

public func goToWeb(_ urlString: String) {
    DispatchQueue.main.async {
        SheetViewController.shared.reset()
        SheetViewController.shared.sheetContentView = AnyView(WebView(urlString))
        SheetViewController.shared.cancelActionText = "closeButtonString".local()
        SheetViewController.shared.sheetVisible = true
    }
}
