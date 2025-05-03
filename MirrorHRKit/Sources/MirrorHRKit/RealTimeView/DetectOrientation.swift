//
//  DetectOrientation.swift
//  
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import SwiftUI
import SharedPkg
import RoberdanToolBox

struct DetectOrientation: View {
    @ObservedObject var deviceOrientation: DeviceOrientation = .shared
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var profileSettings: ProfileGenericSettings
    
    var body: some View {
        if horizontalSizeClass == .compact, verticalSizeClass == .regular { // orientation is portrait}
            Rectangle().fill(Color(tertiaryBgkColor)).frame(height: 0)
                .onAppear(perform: {
                    deviceOrientation.orientation = .portrait
                })
        } else {
            Rectangle().fill(Color(tertiaryBgkColor)).frame(height: 0)
                .onAppear(perform: {
                    deviceOrientation.orientation = .landscape
                    UIScreen.setBrightness(to: profileSettings.brightness)
                })
        }
    }
}
