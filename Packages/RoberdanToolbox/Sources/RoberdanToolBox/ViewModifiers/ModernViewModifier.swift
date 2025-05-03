//
//  ModernViewModifier.swift
//  
//
//  Created by Roberto D’Angelo on 11/06/24.
//

import Foundation
import SwiftUI
import UIKit

// Usage:
// .adaptiveOverlay(lightCornerRadius: 20, darkCornerRadius: 20)
// .adaptiveOverlay(lightCornerRadius: 10, darkCornerRadius: 10)

public struct AdaptiveOverlayModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var lightCornerRadius: CGFloat
    var darkCornerRadius: CGFloat
    var lightShadowRadius: CGFloat
    var darkShadowRadius: CGFloat
    var lightGradient: Gradient
    var darkGradient: Gradient

    public func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    if colorScheme == .dark {
                        LinearGradient(gradient: darkGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            .cornerRadius(darkCornerRadius)
                            .shadow(color: Color.black.opacity(0.5), radius: darkShadowRadius) // Darker shadow for dark mode
                            .opacity(0.85)
                    } else {
                        LinearGradient(gradient: lightGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            .cornerRadius(lightCornerRadius)
                            .shadow(color: Color.gray.opacity(0.3), radius: lightShadowRadius) // Softer shadow for light mode
                            .opacity(0.85)
                    }
                }
            )
            .foregroundColor(.primary) // Adaptive foreground color
    }
}

public extension View {
    func adaptiveOverlay(lightCornerRadius: CGFloat = 20, darkCornerRadius: CGFloat = 20,
                         lightShadowRadius: CGFloat = 10, darkShadowRadius: CGFloat = 10,
                         lightGradient: Gradient = Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                         darkGradient: Gradient = Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)])) -> some View {
        self.modifier(AdaptiveOverlayModifier(lightCornerRadius: lightCornerRadius, darkCornerRadius: darkCornerRadius,
                                              lightShadowRadius: lightShadowRadius, darkShadowRadius: darkShadowRadius,
                                              lightGradient: lightGradient, darkGradient: darkGradient))
    }
}


#if os(iOS)
struct VisualBlurEffectView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
#endif
