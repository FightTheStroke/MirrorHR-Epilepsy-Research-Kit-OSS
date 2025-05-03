//
//  UIScreenExtensions.swift
//
//
//  Created by Roberto D’Angelo on 26/07/21.
//

import Foundation
import SwiftUI

#if os(iOS)
    @available(iOS 13.0, *)
    public extension UIScreen {
        static let screenWidth = UIScreen.main.bounds.size.width
        static let screenHeight = UIScreen.main.bounds.size.height
        static let screenSize = UIScreen.main.bounds.size

        static func setBrightness(to: CGFloat) {
            UIScreen.main.brightness = to
        }
    }
#endif
