//
//  RiftV2App.swift
//  RiftV2
//
//  Created by Brian Kim on 4/20/24.
//

import SwiftUI

@main
struct RiftV2App: App {
    var body: some Scene {
        WindowGroup("Rift Sample App", id: "main") {
            ContentView()
                .environment(PlayerModel())
                .environment(VideoLibrary())
                .background(Color.white.opacity(0.45))
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
