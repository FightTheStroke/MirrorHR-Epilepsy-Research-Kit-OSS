//
//  Helpers.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 18/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI

func getVideoUrl(fileName: String) -> URL? {
    guard let fullPathString = getPath(fileName: fileName) else {
        return nil
    }
    return URL(fileURLWithPath: fullPathString)
}

func getVideoNSURL(fileName: String) -> NSURL? {
    guard let fullPathString = getPath(fileName: fileName) else {
        return nil
    }
    return NSURL(fileURLWithPath: fullPathString)
}

func getPath(fileName: String) -> String? {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    guard let path = paths.first else {
        return nil
    }
    return "\(path)/\(fileName)"
}

func thumbnailFromUrl(url: URL) -> UIImage {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTimeMake(value: 1, timescale: 1)
    var image: UIImage?
    if let imageRef = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
        image = UIImage(cgImage: imageRef)
    }
    return image ?? UIImage(systemName: "photo.on.rectangle.angled")!
}
