//
//  VideoType.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 28/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import MobileCoreServices
import PhotosUI
import SwiftUI
import SharedPkg

enum VideoType {
    case seizure
    case log

    var associatedSymptom: HandledSymptomsEvents {
        switch self {
        case .seizure: 
            return .videoSeizureLog
        case .log:
            return .videoLog
        }
    }
    
    var color: Color {
        switch self {
        case .seizure:
            return .red
        case .log:
            return .green
        }
    }

    var image: Image {
        switch self {
        case .seizure:
            return Image(systemName: "bolt.circle.fill")
        case .log:
            return Image(systemName: "video.circle.fill")
        }
    }

    var message: String {
        switch self {
        case .seizure:
            return seizureLogBtnMsg
        case .log:
            return videoLogBtnMsg
        }
    }
    
    var camera: UIImagePickerController.CameraDevice {
        switch self {
        case .seizure:
            return .rear
        case .log:
            return .front
        }
    }
    
    var fileType: MirrorHRFileTypes {
        switch self {
        case .seizure:
            return .seizureLog
        case .log:
            return .videoLog
        }
    }
}
