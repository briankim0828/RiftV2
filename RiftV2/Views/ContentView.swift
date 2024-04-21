//
//  ContentView.swift
//  RiftV2
//
//  Created by Brian Kim on 4/20/24.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers
import AVKit
import os

struct ContentView: View {
        
    //initialize video player model
    @Environment(PlayerModel.self) private var player
    @Environment(VideoLibrary.self) private var library
    
    @State private var isPickingFile = false
    

#if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @State var immersiveSpaceIsShown = false
#endif
    
    // This is the main view Handler - PlayerView takes over as soon as video plays
    var body: some View {
#if os(macOS) || os(visionOS)
        Group {
            switch player.presentation {
            case .fullWindow:
                // Present the player full window and begin playback.
                PlayerView(video: player.currentItem!)
                    .onAppear {
                        print("ContentView: PlayerViewAppeared")
                        player.play()
                    }
            default:
                // Show the app's content library by default.
                mainView
                    .onAppear { print("ContentView: mainViewAppeared") }
            }
        }
        .onAppear { print("ContentView: ContentViewAppeared") }
#endif
    }
    
    var verticalPadding: Double = 30
    
    func loadVideoWrapperFunction (video: Video) {
        print("ContentView: loadVideoWrapperFunction start")
        player.loadVideo(video, presentation: .fullWindow)
    }
    
    @ViewBuilder
    var mainView: some View {
        NavigationStack() {
            // Wrap the content in a vertically scrolling view.
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: verticalPadding) {

                    Text("Rift V2")
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                        .padding(.leading, 40)
                        .padding(.top, 14)
                        .padding(.bottom, 10)
                    
                    // Displays a horizontally scrolling list of Featured videos.
                    VideoListView(title: "Recommended",
                                  videos: library.videos,
                                  cardSpacing: 30, selectionAction: loadVideoWrapperFunction)
                    
                }
                .padding([.top, .bottom], verticalPadding)
            }
        }
    }
}




