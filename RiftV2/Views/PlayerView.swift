//
//  PlayerView.swift
//  RiftV2
//
//  Created by Brian Kim on 4/20/24.
//

import SwiftUI

/// Constants that define the style of controls a player presents.
enum PlayerControlsStyle {
    /// A value that indicates to use the system interface that AVPlayerViewController provides.
    case system
    /// A value that indicates to use compact controls that display a play/pause button.
    case custom
}

/// A view that presents the video player.
struct PlayerView: View {
    
    let controlsStyle: PlayerControlsStyle
    let video: Video
    @State private var showContextualActions = false
    @Environment(PlayerModel.self) private var model
    
    /// Creates a new player view.
    init(video : Video, controlsStyle: PlayerControlsStyle = .system) {
        print("PlayerView: initializing PlayerView")
        self.video = video
        self.controlsStyle = controlsStyle
    }
    
    var body: some View {
        switch controlsStyle {
        case .system:
            VideoPlayerView(video: video, showContextualActions: showContextualActions)
                .onAppear{
                    print("PlayerView: VideoPlayerViewAppeared")
                }
            
        case .custom:
            //placeholder
            ContentView()
//            InlinePlayerView()
        }
    }
}


