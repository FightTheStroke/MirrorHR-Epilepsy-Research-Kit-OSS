//
//  EndEditing.swift
//
//
//  Created by Roberto D’Angelo on 26/07/21.
//

import Foundation
import UIKit

// hide keyboard on press outside
#if os(iOS)
    @available(iOS 13.0, *)
    public extension UIApplication {
        func endEditing() {
            sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif
