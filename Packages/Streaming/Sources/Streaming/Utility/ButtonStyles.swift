//
//  StreamingManager.swift
//
//
//  Created by Roberto D’Angelo on 12/08/22.
//

import SwiftUI

public struct MultipeerButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(.headline)
            .background(configuration.isPressed ? Color("rw-dark") : Color.accentColor)
            .cornerRadius(9.0)
            .foregroundColor(.white)
    }
}

public struct StreamMessageButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
            Spacer()
        }
        .padding(8)
        .background(configuration.isPressed ? Color("rw-dark") : Color.green)
        .cornerRadius(9.0)
        .foregroundColor(.white)
    }
}

public struct FooterButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color("rw-dark") : .accentColor)
            .font(.headline)
            .padding(8)
    }
}
