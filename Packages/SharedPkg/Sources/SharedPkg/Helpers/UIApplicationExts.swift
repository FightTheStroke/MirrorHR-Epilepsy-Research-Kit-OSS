//
//  UIApplication extensions.swift
//  
//
//  Created by Roberto D’Angelo on 24/05/22.
//

import Foundation
import UIKit
import SwiftUI

#if os(iOS)
let myScenes = UIApplication.shared.connectedScenes
let myWindowScenes = myScenes.first as? UIWindowScene
let myWindow = myWindowScenes?.windows.first
#endif
