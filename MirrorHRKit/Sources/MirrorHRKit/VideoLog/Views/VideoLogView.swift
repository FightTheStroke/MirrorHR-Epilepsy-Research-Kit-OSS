//
//  VideoPlayerView.swift
//  EpilepsyResearchKit2020
//
//  Created by Roberto D’Angelo on 21/03/2020.
//  Copyright © 2020 Roberto D’Angelo. All rights reserved.
//

import AVKit
import Foundation
import SwiftUI
import SharedPkg
import Combine

// AsyncImageLoader for background image loading
class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var loadedImage: UIImage?
    
    func loadImage(from symptom: SymptomsData) {
        // Simulate asynchronous loading
        DispatchQueue.global(qos: .userInitiated).async {
            if let thumbnail = symptom.videoThumbnail {
                self.loadedImage = UIImage(data: thumbnail)!
            } else {
                self.loadedImage = UIImage(systemName: "photo.on.rectangle.angled")!
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.image = self.loadedImage
            }
        }
    }
}

// SwiftUI view for displaying an asynchronously loaded image
struct AsyncImageView: View {
    @StateObject private var loader = AsyncImageLoader()
    let symptom: SymptomsData
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                // Placeholder or loading state
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
            }
        }
        .onAppear {
            loader.loadImage(from: symptom)
        }
    }
}

// VideoLogRowView incorporating AsyncImageView and play button overlay
struct VideoLogRowView: View {
    let symptom: SymptomsData
    var showThumbnailOnly: Bool = false
    var thumbnailWidth: CGFloat = 66
    var thumbnailHeight: CGFloat = 100
    
    init(symptom: SymptomsData, showThumbnailOnly: Bool = false) {
        self.symptom = symptom
        self.showThumbnailOnly = showThumbnailOnly
        if showThumbnailOnly {
            thumbnailWidth = 122
            thumbnailHeight = 200
        }
    }
    
    var body: some View {
        HStack(alignment: .top ) {
            if !showThumbnailOnly {
                SymptomRowCoreInfo(symptom: symptom)
            }
            Spacer()
            ZStack {
                AsyncImageView(symptom: symptom)
                    .frame(width: thumbnailWidth, height: thumbnailHeight, alignment: .top)
                    .clipped()
                    .cornerRadius(5)
                
                if showThumbnailOnly {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44) // Adjust size as needed
                        .foregroundColor(.white) // Adjust color as needed
                }
            }
        }
    }
}


struct VideoLogRowViewOld: View {
    var thumbnailImage: UIImage
    let symptom: SymptomsData
    var showThumbnailOnly: Bool = false
    var thumbnailWidth: CGFloat = 66
    var thumbnailHeight: CGFloat = 100
    
    init(symptom: SymptomsData, showThumbnailOnly: Bool = false) {
        self.symptom = symptom
        self.showThumbnailOnly = showThumbnailOnly
        if showThumbnailOnly {
            thumbnailWidth = 122
            thumbnailHeight = 200
        }
        guard let thumbnail = symptom.videoThumbnail, let videoFilename = symptom.videoFileName, getVideoUrl(fileName: videoFilename) != nil else {
            self.thumbnailImage = UIImage(systemName: "photo.on.rectangle.angled")!
            return
        }
        thumbnailImage = UIImage(data: thumbnail)!
    }
    
    var body: some View {
        HStack(alignment: .top ) {
            if !showThumbnailOnly {
                SymptomRowCoreInfo(symptom: symptom)
            }
            Spacer()
            ZStack {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .frame(width: thumbnailWidth, height: thumbnailHeight, alignment: .top)
                    .clipped()
                    .cornerRadius(5)
                if showThumbnailOnly {
                    // Overlaying play button
                    Image(systemName: "play.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44) // Adjust size as needed
                        .foregroundColor(.white) // Adjust color as needed
                }
            }
        }
    }
}

struct VideoPlayerView: View {
    var videoURL: URL?
    var startDate: Date?
    @State private var showingShareSheet = false
    @StateObject private var playerWrapper = PlayerWrapper()

    init(symptom: SymptomsData) {
        if let videoFilename = symptom.videoFileName, let videoUrl = getVideoUrl(fileName: videoFilename) {
            self.videoURL = videoUrl
        }
        self.startDate = symptom.startDate
    }

    var body: some View {
        VStack {
            if let videoURL = videoURL {
                VideoPlayer(player: playerWrapper.player(for: videoURL))
                    .scaledToFill()
                    .onAppear {
                        playerWrapper.player?.play()
                    }
            } else {
                Text("Video not available")
            }
            Spacer()
        }
        .onDisappear {
            playerWrapper.player?.pause()
        }
        .navigationTitle(Text(startDate?.toStdString() ?? ""))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showingShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up.circle")
                }
                .foregroundColor(.accentColor)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let videoURL = videoURL {
                ShareSheet(activityItems: [videoURL])
            }
        }
    }
}

// PlayerWrapper to handle AVPlayer
class PlayerWrapper: ObservableObject {
    @Published var player: AVPlayer?

    func player(for url: URL) -> AVPlayer {
        if let player = player {
            return player
        } else {
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            return newPlayer
        }
    }
}

// Wrapper for UIActivityViewController to use in SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
