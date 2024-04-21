//
//  VideoPlayerView.swift
//  RiftV2
//
//  Created by Brian Kim on 4/20/24.
//

import AVKit
import SwiftUI

// This view is a SwiftUI wrapper over `AVPlayerViewController`.
struct VideoPlayerView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        task{
//            print("updateUIViewController called")
//        }
    }

    @Environment(PlayerModel.self) private var model
    @Environment(VideoLibrary.self) private var library
    
    let showContextualActions: Bool
    let video: Video
    
    init(video: Video, showContextualActions: Bool) {
        print("VideoPlayerView: initializing VideoPlayerView")
        self.video = video
        self.showContextualActions = showContextualActions
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        print("VideoPlayerView: running makeUIViewController")
        
        
        // Create a player view controller.
//        let controller = model.makePlayerViewController(videoURL: library.videos[0].url)
        let videoFileName = video.fileName
        guard let url = Bundle.main.url(forResource: videoFileName, withExtension: nil) else {
            fatalError("Couldn't find \(videoFileName) in main bundle.")
        }
        let controller = model.makePlayerViewController(videoURL : url)

        print("VideoPayerView: 1")
        
        // Enable PiP on iOS and tvOS.
        controller.allowsPictureInPicturePlayback = true
        
        // Return the configured controller object.
        print("VideoPlayerView: finished makeUIViewController")
        return controller
    }
    
    var upNextAction: UIAction? {
        // If there's no video loaded, return nil.
        guard let video = model.currentItem else { return nil }

        // Find the next video to play.
        guard let nextVideo = library.findVideoInUpNext(after: video) else { return nil }
        
        return UIAction(title: "Play Next", image: UIImage(systemName: "play.fill")) { _ in
            // Load the video for full-window presentation.
            model.loadVideo(nextVideo, presentation: .fullWindow)
        }
    }
}


