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
    
    @State private var showingVideoPicker = false
    @State private var videoURL: URL?
    @State private var uploadStatus: String = ""


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
    
    func uploadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // Define the URL for your upload endpoint
        let uploadURL = URL(string: "https://yourserver.com/upload")!

        // Create a URLRequest
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        // Start uploading the video
        let task = URLSession.shared.uploadTask(with: request, fromFile: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            DispatchQueue.main.async {
                if let data = data, let url = try? JSONDecoder().decode(URL.self, from: data) {
                    completion(.success(url))
                } else {
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            }
        }

        task.resume()
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
                    
                    HStack{
                        Spacer()
                        
                        Button("Pick Video from Photos Library") {
                            print("ContentView: Photos Library Button Pressed")
                            showingVideoPicker = true
                        }
                        .sheet(isPresented: $showingVideoPicker) {
                            VideoPicker(selectedVideoURL: $videoURL)
                        }
                        .buttonStyle(.bordered)
                        
                        if let videoURL = videoURL {
                                        Button("Upload Video") {
                                            print("ContentView: upload button pressed")
                                            uploadVideo(url: videoURL) { result in
                                                switch result {
                                                case .success(let url):
                                                    uploadStatus = "Upload Successful: \(url.absoluteString)"
                                                case .failure(let error):
                                                    uploadStatus = "Upload Failed: \(error.localizedDescription)"
                                                }
                                            }
                                        }
                                        .buttonStyle(.bordered)
                                    }
                        
                        Spacer()
                    }
                    
                    
                    HStack{
                        Spacer()
                        Text(uploadStatus)
                        Spacer()
                    }
                    
                }
                .padding([.top, .bottom], verticalPadding)
            }
        }
    }
}




