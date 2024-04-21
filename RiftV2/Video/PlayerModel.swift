//
//  PlayerModel.swift
//  RiftV2
//
//  Created by Brian Kim on 4/20/24.
//

/*
A model object that manages the playback of video.
*/

import AVKit
import GroupActivities
import Combine
import Observation
import OSLog

/// The presentation modes the player supports.
enum Presentation {
    /// Indicates to present the player as a child of a parent user interface.
    case inline
    /// Indicates to present the player in full-window exclusive mode.
    case fullWindow
}

@Observable class PlayerModel {
    
    let logger = Logger()
    
    /// A Boolean value that indicates whether playback is currently active.
    private(set) var isPlaying = false
    
    /// A Boolean value that indicates whether playback of the current item is complete.
    private(set) var isPlaybackComplete = false
    
    /// The presentation in which to display the current media.
    private(set) var presentation: Presentation = .inline
    
    /// The currently loaded video.
    private(set) var currentItem: Video? = nil
    
    /// A Boolean value that indicates whether the player should propose playing the next video in the Up Next list.
    private(set) var shouldProposeNextVideo = false
    
    /// An object that manages the playback of a video's media.
    private var player = AVPlayer()
    
    /// The currently presented player view controller.
    ///
    /// The life cycle of an `AVPlayerViewController` object is different than a typical view controller. In addition
    /// to displaying the player UI within your app, the view controller also manages the presentation of the media
    /// outside your app UI such as when using AirPlay, Picture in Picture, or docked full window. To ensure the view
    /// controller instance is preserved in these cases, the app stores a reference to it here (which
    /// is an environment-scoped object).
    ///
    /// This value is set by a call to the `makePlayerViewController()` method.
    private var playerViewController: AVPlayerViewController? = nil
    private var playerViewControllerDelegate: AVPlayerViewControllerDelegate? = nil
    
    private(set) var shouldAutoPlay = true
    
    // An object that manages the app's SharePlay implementation.
//    private var coordinator: VideoWatchingCoordinator! = nil
    
    /// A token for periodic observation of the player's time.
    private var timeObserver: Any? = nil
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        Task {
            await configureAudioSession()
        }
    }
    
    /// Creates a new player view controller object.
    /// - Returns: a configured player view controller.
    func makePlayerViewController(videoURL : URL) -> AVPlayerViewController {
        
        print("PlayerModel: Running PlayerModel.makePlayerViewController")
        let delegate = PlayerViewControllerDelegate(player: self)
        let controller = AVPlayerViewController()
        player = AVPlayer(url: videoURL)
        controller.player = player
        controller.delegate = delegate

        // Set the model state
        playerViewController = controller
        playerViewControllerDelegate = delegate
        
        print("PlayerModel: controller made & returned")
        return controller
    }
    
    /// Configures the audio session for video playback.
    private func configureAudioSession() async {
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure the audio session for playback. Set the `moviePlayback` mode
            // to reduce the audio's dynamic range to help normalize audio levels.
            try session.setCategory(.playback, mode: .moviePlayback)
        } catch {
            logger.error("Unable to configure audio session: \(error.localizedDescription)")
        }
    }
    
    /// Loads a video for playback in the requested presentation.
    /// - Parameters:
    ///   - video: The video to load for playback.
    ///   - presentation: The style in which to present the player.
    ///   - autoplay: A Boolean value that indicates whether to auto play that the content when presented.
    func loadVideo(_ video: Video, presentation: Presentation, autoplay: Bool = true) {
        // Update the model state for the request.
        currentItem = video
        shouldAutoPlay = autoplay
        isPlaybackComplete = false

        // In visionOS, configure the spatial experience for either .inline or .fullWindow playback.
        configureAudioExperience(for: presentation)

        // Set the presentation, which typically presents the player full window.
        self.presentation = presentation
        print("PlayerModel: video loaded & PlayerModel.presentation = .fullWindow")
   }
    
    private func replaceCurrentItem(with video: Video) {
        // Create a new player item and set it as the player's current item.
        let playerItem = AVPlayerItem(url: video.resolvedURL)
        // Set external metadata on the player item for the current video.
//        playerItem.externalMetadata = createMetadataItems(for: video)
        // Set the new player item as current, and begin loading its data.
        player.replaceCurrentItem(with: playerItem)
        logger.debug("🍿 \(video.title) enqueued for playback.")
    }
    
    /// Clears any loaded media and resets the player model to its default state.
    func reset() {
        print("PlayerModel: calling reset")
        playerViewController = nil
        playerViewControllerDelegate = nil
        // Reset the presentation state on the next cycle of the run loop.
//        Task { @MainActor in
//            print("changing presentation")
//            self.presentation = .inline
//        }
        self.presentation = .inline
        currentItem = nil
        player.replaceCurrentItem(with: nil)
    }
    
    /// Configures the user's intended spatial audio experience to best fit the presentation.
    /// - Parameter presentation: the requested player presentation.
    private func configureAudioExperience(for presentation: Presentation) {
        #if os(visionOS)
        do {
            let experience: AVAudioSessionSpatialExperience
            switch presentation {
            case .inline:
                // Set a small, focused sound stage when watching trailers.
                experience = .headTracked(soundStageSize: .small, anchoringStrategy: .automatic)
            case .fullWindow:
                // Set a large sound stage size when viewing full window.
                experience = .headTracked(soundStageSize: .large, anchoringStrategy: .automatic)
            }
            try AVAudioSession.sharedInstance().setIntendedSpatialExperience(experience)
        } catch {
            logger.error("Unable to set the intended spatial experience. \(error.localizedDescription)")
        }
        #endif
    }

    
    func play() {
        print("PlayerModel: play started")
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func togglePlayback() {
        player.timeControlStatus == .paused ? play() : pause()
    }

    /// A coordinator that acts as the player view controller's delegate object.
    final class PlayerViewControllerDelegate: NSObject, AVPlayerViewControllerDelegate {
        
        let player: PlayerModel
        
        init(player: PlayerModel) {
            self.player = player
        }
        
        #if os(visionOS)
        // The app adopts this method to reset the state of the player model when a user
        // taps the back button in the visionOS player UI.
        func playerViewController(_ playerViewController: AVPlayerViewController,
                                  willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            Task { @MainActor in
                // Calling reset dismisses the full-window player.
                player.reset()
            }
        }
        #endif
    }
}
