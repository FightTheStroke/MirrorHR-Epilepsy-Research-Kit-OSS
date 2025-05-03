//
//  BackGroundProcessing.swift
//
//
//  Created by Roberto D’Angelo on 26/07/21.
//

import Foundation
import SwiftUI

public extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                background?()
                if let completion = completion {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        completion()
                    }
                }
            }
        }
    }
}
