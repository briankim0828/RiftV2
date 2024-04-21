//
//  VideoCardView.swift
//  RiftV2
//
//  Created by Brian Kim on 4/20/24.
//

import SwiftUI
import AVFoundation
import UIKit
import SwiftUI

struct VideoCardView: View {
    @ObservedObject var TVM = ThumbnailViewModel()
    let video: Video
    
    init(video: Video) {
        self.video = video
        // Optionally load the thumbnail here if the URL is known and static
        guard let url = Bundle.main.url(forResource: video.fileName, withExtension: nil) else {
            fatalError("Couldn't find \(video.fileName) in main bundle.")
        }
        self.TVM.loadThumbnail(from: url) // Replace with actual video URL property if available
    }
    
    var body: some View {
        VStack {

            if let thumbnail = TVM.thumbnail {
                thumbnail
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 395, height: 220)
                    .cornerRadius(20.0)
            } else {
                // Placeholder view if the thumbnail isn't loaded yet
                Color.gray
                    .frame(width: 395, height: 220)
                    .cornerRadius(20.0)
            }

            VStack(alignment: .leading) {

                HStack {
                    Text(video.title)
                        .font(.title)
                    Text("\(video.info.releaseYear) | \(video.info.duration)")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(.secondary)
                .padding(.top, 10)
            }
            .padding(20)
        }
        .background(.thinMaterial)
        .frame(width: 395)
        .shadow(radius: 5)
        .hoverEffect()
        .cornerRadius(20)
        .background(Color.black.opacity(0.48).cornerRadius(30))
        .ignoresSafeArea()
    }
}
