//
//  ButtonStyles.swift
//  RoberdanToolBox
//
//  Created by Roberto D’Angelo on 11/7/24.
//

import SwiftUI

/// Un `ButtonStyle` personalizzato che applica uno stile primario ai pulsanti.
///
/// - Parameters:
///   - backgroundColor: Il colore di sfondo del pulsante. Default è `Color.blue`.
///   - foregroundColor: Il colore del testo del pulsante. Default è `Color.white`.
///   - font: Il font del testo del pulsante. Default è `.headline`.
///   - cornerRadius: Il raggio degli angoli arrotondati del pulsante. Default è `10`.
///   - padding: Il padding interno del pulsante. Default è `16`.
public struct PrimaryButtonStyle: ButtonStyle {
    public var backgroundColor: Color
    public var foregroundColor: Color
    public var font: Font
    public var cornerRadius: CGFloat
    public var padding: CGFloat

    public init(
        backgroundColor: Color = Color.blue,
        foregroundColor: Color = Color.white,
        font: Font = .headline,
        cornerRadius: CGFloat = 10,
        padding: CGFloat = 16
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.font = font
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundColor(foregroundColor)
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            .cornerRadius(cornerRadius)
            .padding(.horizontal)
    }
}
