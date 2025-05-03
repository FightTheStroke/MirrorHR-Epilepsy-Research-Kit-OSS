//
//  SheetViewController.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 04/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - SheetViewController
/// It handles the main Sheet View in all it's options
public final class SheetViewController: ObservableObject {
    public static let shared = SheetViewController()

    @Published public var sheetVisible: Bool = false
    @Published public var sheetContentView = AnyView(EmptyView())
    public var navigationTitle: String = ""
    public var cancelAction: CancelActionCall?
    public var okAction: OkActionCall?
    public var dismissAction: OnSheetDismissCall?
    public var okActionText: String = ""
    public var okActionImage: String = ""
    public var cancelActionText: String = ""
    public var cancelActionImage: String = ""
    var showNavTabBarTitle: Bool = true
    public var presentationDetents: Set<PresentationDetent> = [.large]
        
    private init() {
        // to secure it's a singleton
    }
    
    public func reset() {
        sheetVisible = false
        showNavTabBarTitle = true
        navigationTitle = ""
        cancelAction = Self.defaultCancelAction
        okAction = Self.defaultOkAction
        dismissAction = Self.defaultOnsSheetDismissCall
        okActionText = ""
        okActionImage = ""
        cancelActionText = ""
        cancelActionImage = ""
    }
    
    public func closeSheet() {
        if sheetVisible {
            DispatchQueue.main.async {
                self.sheetVisible = false
            }
        }
    }
}

extension SheetViewController {
    // MARK: default sheet view actions

    public typealias OkActionCall = () -> Void
    public typealias CancelActionCall = () -> Void
    public typealias OnSheetDismissCall = () -> Void

    static var sheetDefaultCancelActionCall: CancelActionCall {
        {
            if SheetViewController.shared.sheetVisible {
                SheetViewController.shared.closeSheet()
            }
        }
    }

    static var defaultOkAction: OkActionCall {
        {
            self.sheetDefaultCancelActionCall()
        }
    }

    static var defaultCancelAction: CancelActionCall {
        {
            self.sheetDefaultCancelActionCall()
        }
    }

    static var defaultOnsSheetDismissCall: OnSheetDismissCall {
        {
            self.sheetDefaultCancelActionCall()
        }
    }

    var hasCancelButton: Bool {
        cancelActionText != "" || cancelActionImage != ""
    }

    var hasOkButton: Bool {
        okActionText != "" || okActionImage != ""
    }
}
