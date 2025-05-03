//
//  KeyWindow.swift
//  
//
//  Created by Roberto D’Angelo on 02/09/22.
//

import Foundation
import UIKit

#if os(iOS)
internal let keyWindow = UIApplication.shared.connectedScenes
    .filter({$0.activationState == .foregroundActive})
    .compactMap({$0 as? UIWindowScene})
    .first?.windows
    .filter({$0.isKeyWindow}).first
#endif
