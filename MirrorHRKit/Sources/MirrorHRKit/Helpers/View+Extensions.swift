//
//  View+Extensions.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 04/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import UIKit

extension View {
    var animationDurationMS: Int { 300 }

    public func supportedOrientation(_ orientations: UIInterfaceOrientationMask, resetTo: UIInterfaceOrientationMask = .portrait) -> some View {
        onAppear {
            AppDelegate.orientationLock = orientations
            DispatchQueue.main.async {
                let scenes = UIApplication.shared.connectedScenes
                guard let windowScenes = scenes.first as? UIWindowScene, let window = windowScenes.windows.first, let currentOrientation = window.windowScene?.interfaceOrientation else {
                    // If this happens, this method has been triggered without anything on the screen. So we shouldn't try to do
                    // anything.
                    return
                }

                let beforeAppearOrientation = UIDevice.current.orientation

                if
                    AppDelegate.orientationLock.contains(beforeAppearOrientation.toMask),
                    beforeAppearOrientation != currentOrientation.toDeviceOrientation
                {
                    windowScenes.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
        .onDisappear {
            // Reset the previous supported orientation
            AppDelegate.orientationLock = resetTo

            DispatchQueue.main.async {
                let beforeDisappearOrientation = UIDevice.current.orientation

                // If the device is currently in a state that is not supported, try to rotate it back.
                if !AppDelegate.orientationLock.contains(beforeDisappearOrientation.toMask) {
                    UIDevice.current.setValue(resetTo.toOrientation.rawValue, forKey: "orientation")
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .forEach { $0.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations() }
                }
            }
        }
    }
}

extension UIDeviceOrientation {
    var toMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .unknown, .faceDown, .faceUp:
            fallthrough
        @unknown default:
            return .portrait
        }
    }
}


extension UIInterfaceOrientation {
    var toDeviceOrientation: UIDeviceOrientation {
        switch self {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .unknown:
            fallthrough
        @unknown default:
            return .portrait
        }
    }
}

extension UIInterfaceOrientationMask {
    var toOrientation: UIInterfaceOrientation {
        switch self {
        case .all, .allButUpsideDown, .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscape, .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
}

#if os(iOS)
internal let keyWindow = UIApplication.shared.connectedScenes
    .filter({$0.activationState == .foregroundActive})
    .compactMap({$0 as? UIWindowScene})
    .first?.windows
    .filter({$0.isKeyWindow}).first
#endif
