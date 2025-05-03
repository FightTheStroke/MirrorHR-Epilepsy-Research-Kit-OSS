//
//  ContainersViewsStructs.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 25/09/2020.
//

import Foundation
import SharedPkg
import SwiftUI

struct MyRoundedShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(defaultViewCornerRadius)
            .shadow(radius: defaultShadowRadius)
    }
}

struct VisualBlurEffectView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context _: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct MyHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .edgesIgnoringSafeArea(.horizontal)
            .background(.ultraThinMaterial)
            .cornerRadius(defaultViewCornerRadius)
            .shadow(radius: defaultShadowRadius)
    }
}

struct FormSectionHeaderText: ViewModifier {
    var color: Color = .primary
    
    init(color: Color? = nil) {
        self.color = color ?? .primary
    }
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(color)
    }
}

struct MyCoreContentModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(
                defaultViewCornerRadius, corners: [.topLeft, .topRight]
            )
            .padding(.top, 5)
    }
}

struct MyRadialViewModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let isList: Bool
    
    init(isList: Bool) {
        self.isList = isList
    }
    
    func body(content: Content) -> some View {
        let bck = colorScheme == .dark ? darkGradient : lightGradient
        if isList {
            content
                .scrollContentBackground(.hidden)
                .background(
                    bck
                        .edgesIgnoringSafeArea(.all)
                )
        } else {
            content
                .background(
                    bck
                        .edgesIgnoringSafeArea(.all)
                )
        }
    }
}
