//
//  ButtonLabel.swift
//
//
//  Created by Roberto D’Angelo on 05/06/24.
//

import Foundation
import SwiftUI
import RoberdanToolBox

public struct MyActionableButton: View {
    @Environment(\.colorScheme) var colorScheme
    let idString: String
    let activeMsg: String
    let disabledMsg: String
    let action: () -> Void
    var timer: Timer?
    let activatingDelay: TimeInterval
    
    @State private var isActive: Bool = true
    
    public init(
        idString: String,
        activeMsg: String,
        disabledMsg: String = "",
        activatingDelay: TimeInterval = 15,
        action: @escaping () -> Void
    ) {
        self.activeMsg = activeMsg
        self.disabledMsg = disabledMsg
        self.action = action
        self.idString = idString
        self.activatingDelay = activatingDelay
    }
    
    public var body: some View {
        Group {
            if isActive {
                Text(activeMsg)
            } else {
                ProgressView()
            }
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .background(.blue)
        .cornerRadius(defaultCornerRadius)
        .shadow(radius: defaultShadowRadius)
        .disabled(!isActive)
        .opacity(colorScheme == .dark ? darkOpacity : lightOpacity)
        .onTapGesture {
            isActive = false
            action()
            // Timeout after 60 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + activatingDelay) {
                self.isActive = true
            }
        }
    }
}

// MARK: - ActionButton

public struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        MyActionableButton(idString: "ActionButton" + "(title))", activeMsg: title, activatingDelay: 1, action: {
            action()
        })
    }
}
