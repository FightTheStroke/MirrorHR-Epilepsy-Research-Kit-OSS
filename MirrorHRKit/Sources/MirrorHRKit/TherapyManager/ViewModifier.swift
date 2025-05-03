//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 30/04/22.
//

import Foundation
import SwiftUI
import SharedPkg

@available(iOS 15, *)
public struct TherapyToolbarSaveViewModifier: ViewModifier {
    let navigationTitle: String
    let backBtnTitle: String
    let saveAction: () -> Void
    
    @State private var saved: Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Binding var saveEnabled: Bool
    
    func save() {
        saveAction()
        saved = true
        dismiss()
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationBarTitle(navigationTitle)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if saved {
                            dismiss()
                        } else {
                            therapyManager.alertYesNoMsg = therapyAlertYesNoSaveMsg + (saveEnabled ? "" : "\n\(missingFieldsALertMsg)")
                            if saveEnabled {
                                therapyManager.alertYesAction = save
                            } else {
                                therapyManager.alertYesAction = {}
                            }
                            
                            therapyManager.alertNoAction = {
                                dismiss()
                            }
                            therapyManager.showYesNoAlert = true
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text(backBtnTitle)
                        }
                    })
                    .foregroundColor(.accentColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(saveBtnMsg.uppercased()) {
                        save()
                    }
                    .font(.body.bold())
                    .disabled(!saveEnabled)
                    .foregroundColor(.accentColor)
                }
            }
    }
}
