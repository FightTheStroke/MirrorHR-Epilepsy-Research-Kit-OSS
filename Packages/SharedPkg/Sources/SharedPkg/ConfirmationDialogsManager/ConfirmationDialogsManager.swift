//
//  ConfirmationsDialogManager.swift
//
//  Created by Roberto D’Angelo on 14/10/23.
//

import Foundation
import SwiftUI

final public class ConfirmationsDialogManager: ObservableObject {
    static public let shared = ConfirmationsDialogManager()
    
    @Published public var isPresented: Bool
    public var title: String
    public var actions: AnyView
    public var message: String
    
    private init() {
        isPresented = false
        title = "AlertConfirmMsgText".local()
        actions = AnyView(EmptyView())
        message = "therapyAlertYesNoSaveMsg".local()
    }

    public func show(title: String, message: String, actions: AnyView) {
        self.title = title.local()
        self.message = message.local()
        self.actions = actions
        self.isPresented = true
    }
    
    public func dismiss() {
        isPresented = false
    }
}
