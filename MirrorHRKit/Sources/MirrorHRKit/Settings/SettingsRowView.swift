//
//  SettingsLabelView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 05/12/20.
//  Copyright © 2020 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg

// MARK: - Models

enum SettingsRowKind: Identifiable {
    case textField(name: String, binding: Binding<String>)
    case content(name: String, text: String)
    case message(name: String, message: String)
    case link(name: String, label: String, destination: URL)
    case toggle(name: String, binding: Binding<Bool>, foregroundColor: Color = .primary, caption: String? = nil, isEnabled: Bool = true)
    case button(name: String, image: String, action: () -> Void)
    case custom(name: String, AnyView, isEnabled: Bool = true)
    case simpleIntPicker(name: String, options: [Int], binding: Binding<Int>)
    
    var id: String {
        switch self {
        case let .textField(name, _),
            let .content(name, _),
            let .link(name, _, _),
            let .toggle(name, _, _, _, _),
            let .button(name, _, _),
            let .custom(name, _, _),
            let .message(name, _),
            let .simpleIntPicker(name, _, _):
            return name + UUID().uuidString
        }
    }
}

// MARK: - View

struct SettingsRowView: View {
    var kind: SettingsRowKind
    
    @ViewBuilder
    var body: some View {
        VStack {
            switch self.kind {
            case let .content(name, text):
                self.text(name: name, content: text)
            case let .textField(name, binding):
                self.textField(name: name, binding: binding)
            case let .link(name, label, url):
                self.link(name: name, label: label, url: url)
            case let .button(name, image, action):
                self.button(name: name, image: image, action: action)
            case let .toggle(name, binding, foregroundColor, caption, isEnabled):
                self.toggle(name: name, binding: binding, caption: caption, foregroundColor: foregroundColor).disabled(!isEnabled)
            case let .simpleIntPicker(name, options, binding):
                self.simpleIntPicker(name: name, options: options, binding: binding)
            case let .custom(_, view, isEnabled):
                HStack {
                    view.disabled(!isEnabled)
                }
            case .message(_ , message: let message):
                self.messageView(message)
            }
        }
    }
}

// MARK: - Helpers

extension SettingsRowView {
    func text(name: String, content: String) -> some View {
        HStack {
            labelWith(name: name)
            Text(content)
        }
    }
    
    func textField(name: String, binding: Binding<String>) -> some View {
        VStack {
            MyTextField(fieldName: name, bindingString: binding, isMandatory: false, split2Rows: true, showFieldName: true, textAlignment: .center)
        }
    }
    
    func link(name: String, label: String, url: URL) -> some View {
        HStack {
            labelWith(name: name)
            Link(label, destination: url)
        }
    }
    
    func button(name: String, image: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Label(name, systemImage: image)
                .labelStyle(.automatic)
        }
        .buttonStyle(.automatic)
    }
    
    func toggle(name: String, binding: Binding<Bool>, caption: String?, foregroundColor: Color) -> some View {
        HStack {
            Toggle(isOn: binding) {
                VStack(alignment: .leading) {
                    Text(name)
                    if let caption = caption {
                        Text(caption)
                    }
                }
            }.foregroundColor(foregroundColor)
        }
    }
    
    func messageView(_ message: String) -> some View {
        Text(message)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    func labelWith(name: String) -> some View {
        HStack {
            Text(name)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
    
    static func labelWith(name: String) -> some View {
        HStack {
            Text(name)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
    
    func simpleIntPicker(name: String, options: [Int], binding: Binding<Int>) -> some View {
        HStack {
            Picker(selection: binding, label: Text(name)) {
                ForEach(options, id: \.self) { index in
                    Text("\(index)")
                }
            }
        }
    }
}
