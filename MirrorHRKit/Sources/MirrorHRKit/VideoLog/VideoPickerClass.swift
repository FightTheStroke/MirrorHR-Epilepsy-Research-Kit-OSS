//
//  SeizureRecordingView.swift
//  EpilepsyResearchKit2020
//
//  Created by Roberto D’Angelo on 21/03/2020.
//  Copyright © 2020 Roberto D’Angelo. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import MobileCoreServices
import PhotosUI
import SPConfetti
import SwiftUI
import SharedPkg

// MARK: - Video Picker
struct VideoPicker: UIViewControllerRepresentable {
    var videoType: VideoType
    private let picker = UIImagePickerController()
    private let onDismiss: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode

    init(videoType: VideoType, onDismiss: @escaping () -> Void) {
        self.videoType = videoType
        self.onDismiss = onDismiss
    }

    public func startCapture(completion: @escaping (_ started: Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [self] in
            let videoStarted = picker.startVideoCapture()
            if videoStarted {
                completion(true)
                mainDebugger.append("VideoPicker automatically started recording", .greenFlag)
            } else {
                mainDebugger.append("VideoPicker DID NOT automatically start", .error, sourceModule: "VideoPickerClass startCapture")
                completion(false)
            }
        }
    }

    public func stopCapture() {
        if picker.isBeingDismissed || picker.presentingViewController == nil {
            mainDebugger.append("VideoPicker: stopCapture was called when picker was not active", .error, sourceModule: "VideoPicker")
            return
        }
        picker.stopVideoCapture()
        mainDebugger.append("VideoPicker: video recording stopped", .greenFlag)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraDevice = videoType.camera
            picker.mediaTypes = [UTType.movie.identifier]
            picker.cameraCaptureMode = .video
            picker.allowsEditing = false
            picker.showsCameraControls = false
            picker.videoQuality = .typeHigh
            picker.cameraFlashMode = .off
        } else {
            // Notifica l'utente che la fotocamera non è disponibile
            mainDebugger.append("Camera is not available on this device.", .error, sourceModule: "imagePickerController")
            picker.sourceType = .photoLibrary
        }
        
        return picker
    }

    public func updateUIViewController(_: UIImagePickerController, context _: Context) {
        // nothing to do
    }

    func makeCoordinator() -> VideoCoordinator {
        VideoCoordinator(videoType: videoType, onDismiss: onDismiss)
    }
}

public final class VideoCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private let onDismiss: () -> Void

    let videoType: VideoType

    init(videoType: VideoType, onDismiss: @escaping () -> Void) {
        self.videoType = videoType
        self.onDismiss = onDismiss
    }

    // MARK: SAVING VIDEOLOG
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil) // Dismiss picker correttamente

        if let selectedVideo: URL = info[.mediaURL] as? URL {
            onDismiss()
            if videoType == .log {
                SPConfetti.startAnimating(.fullWidthToDown, particles: [.triangle, .arc], duration: 1)
            }
            DispatchQueue.global(qos: .background).async {
                do {
                    let genericVideoLog = SymptomLog(self.videoType.associatedSymptom, startDate: Date())
                    let videoData = try Data(contentsOf: selectedVideo)
                    let url = getVideoUrl(fileName: genericVideoLog.videoFileName!)
                    try videoData.write(to: url!, options: .atomic)
                    genericVideoLog.saveAndAnalyzeVideoLog { savedStatus in
                        DispatchQueue.main.async {
                            mainDebugger.append("Video/Seizure Log saved status: \(savedStatus)", .justALog)
                        }
                    }
                } catch {
                    mainDebugger.append("I'm sorry I was not able to append the video :( - Error: \(error)", .error, sourceModule: "imagePickerController")
                }
            }
        }
    }
}
