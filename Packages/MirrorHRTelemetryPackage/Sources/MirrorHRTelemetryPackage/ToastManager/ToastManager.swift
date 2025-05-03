//
//  ToasterView.swift
//
//
//  Created by Roberto D’Angelo on 26/02/23.
//

import Foundation
import SwiftUI
private let btnDefaultBackgroundGradient = LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
private let toastBckGradient = LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(1), Color.blue.opacity(1)]), startPoint: .topLeading, endPoint: .bottomTrailing)

public struct ToastView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: () -> Content
    
    public var body: some View {
        if isPresented {
            GeometryReader { geometry in
                HStack {
                    Spacer()
                    content()
                        .padding()
                        .background(toastBckGradient)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.move(edge: .top))
                        .offset(y: 10)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                    Spacer()
                }
            }
        }
    }
}

// ToastManager
public class ToastManager: ObservableObject {
    public static let shared: ToastManager = ToastManager()

    private var toastQueue: [(message: String, image: String)] = []
    private var isAnimating: Bool = false

    @Published public var isPresented = false
    public var label: AnyView = AnyView(EmptyView())

    public func showToast(message: String, image: String) {
        DispatchQueue.main.async {
            self.toastQueue.append((message: message, image: image))
            self.showNextToast()
        }
    }

    private func showNextToast() {
        guard !isAnimating, !toastQueue.isEmpty else { return }

        let toast = toastQueue.removeFirst()
        self.label = AnyView(Label(toast.message, systemImage: toast.image))
        self.isPresented = true

        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.isPresented = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Add a delay
                self.isAnimating = false
                self.showNextToast() // Show next toast if any
            }
        }
    }
}


public extension View {
    func showToast<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            ToastView(isPresented: isPresented, content: content)
        }
    }
}

struct ToasterViewSample: View {
    @ObservedObject private var toastManager: ToastManager = ToastManager()
    
    var body: some View {
        Button("Show Toast") {
            toastManager.showToast(message: "ciao a te", image: "plus")
        }
        .showToast(isPresented: $toastManager.isPresented) {
            AnyView(toastManager.label)
        }
    }
}

struct ToasterViewSample_Previews: PreviewProvider {
    static var previews: some View {
        ToasterViewSample()
    }
}

