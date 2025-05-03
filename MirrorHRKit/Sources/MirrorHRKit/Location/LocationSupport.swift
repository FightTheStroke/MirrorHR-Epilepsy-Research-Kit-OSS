//
//  LocationSupport.swift
//
//
//  Created by Roberto D’Angelo on 12/06/24.
//

import Foundation
import SwiftUI

public func openInMaps(latitude: Double, longitude: Double) {
    let url = URL(string: "http://maps.apple.com/?ll=\(latitude),\(longitude)")!
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
