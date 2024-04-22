
//
//  VideoLibrary.swift
//  Rift
//
//  Created by Brian Kim on 3/10/24.
//

import Foundation
import SwiftUI
import Observation

/// An object that manages the app's video content.
///
/// The app puts an instance of this class into the environment so it can retrieve and
/// update the state of video content in the library.
@Observable class VideoLibrary {
    
    private(set) var videos = [Video]()
    private(set) var upNext = [Video]()
    
    init() {
        // Load all videos available in the library.
        videos = loadVideos()
    }
    
    /// Loads the video content for the app.
    private func loadVideos() -> [Video] {
        let filename = "Videos.json"
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        // Parse and load the Video data from the JSON file.
        let videos: [Video] = load(url)
        // Filter the results to only those playable on the current platform.
        return videos.filter { $0.isPlayable }
    }

    
    private func load<T: Decodable>(_ url: URL, as type: T.Type = T.self) -> T {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            fatalError("Couldn't load \(url.path):\n\(error)")
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(url.lastPathComponent) as \(T.self):\n\(error)")
        }
    }
}

