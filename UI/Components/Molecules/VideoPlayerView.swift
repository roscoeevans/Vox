import SwiftUI
import AVKit
import Combine

struct VideoPlayerView: View {
    let videoURL: URL
    let aspectRatio: AspectRatio?
    let thumbnail: String?
    let alt: String?
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showControls = true
    @State private var hideControlsTask: Task<Void, Never>?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @AppStorage("autoPlayVideos") private var autoPlayEnabled = true
    @AppStorage("muteByDefault") private var muteByDefault = true
    
    var body: some View {
        ZStack {
            // Video player or placeholder
            if let player = player, !hasError {
                VideoPlayer(player: player)
                    .disabled(true) // Disable default controls
                    .background(Color.black)
                    .onTapGesture {
                        if !showControls {
                            // If controls are hidden, toggle play/pause and show controls
                            togglePlayPause()
                            showControlsTemporarily()
                        } else {
                            // If controls are visible, just reset the hide timer
                            showControlsTemporarily()
                        }
                    }
            } else {
                // Thumbnail placeholder or error state
                ZStack {
                    if let thumbnailURL = thumbnail,
                       let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(LinearGradient.voxSubtleGradient.opacity(0.3))
                        }
                    } else {
                        Rectangle()
                            .fill(LinearGradient.voxSubtleGradient.opacity(0.3))
                    }
                    
                    if hasError {
                        // Error state
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(LinearGradient.voxWarmGradient)
                            
                            Text("Unable to load video")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: {
                                hasError = false
                                setupPlayer()
                            }) {
                                Text("Retry")
                                    .font(.caption)
                                    .foregroundStyle(LinearGradient.voxCoolGradient)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if isLoading {
                        // Loading state
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .tint(Color.white)
                    } else {
                        // Play button overlay
                        Button(action: {
                            setupPlayer()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                                    .foregroundStyle(LinearGradient.voxCoolGradient)
                            }
                        }
                    }
                }
            }
            
            // Custom controls overlay
            if player != nil && !hasError {
                ZStack {
                    // Mute button in top right
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: toggleMute) {
                                Image(systemName: player?.isMuted == true ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                            .background(.ultraThinMaterial.opacity(0.7))
                                            .clipShape(Circle())
                                    )
                            }
                            .padding(.trailing, 12)
                            .padding(.top, 12)
                        }
                        Spacer()
                    }
                    
                    // Centered controls
                    HStack(spacing: 30) {
                        // Skip backward button
                        Button(action: skipBackward) {
                            Image(systemName: "gobackward.10")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                        .background(.ultraThinMaterial.opacity(0.7))
                                        .clipShape(Circle())
                                )
                        }
                        
                        // Play/Pause button
                        Button(action: togglePlayPause) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                        .background(.ultraThinMaterial.opacity(0.7))
                                        .clipShape(Circle())
                                )
                        }
                        
                        // Skip forward button
                        Button(action: skipForward) {
                            Image(systemName: "goforward.10")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                        .background(.ultraThinMaterial.opacity(0.7))
                                        .clipShape(Circle())
                                )
                        }
                    }
                    
                    // Progress bar and time at the bottom
                    VStack {
                        Spacer()
                        
                        // Time display above progress bar
                        HStack {
                            Text(formatTime(currentTime))
                                .font(.caption2)
                                .foregroundColor(.white)
                                .monospacedDigit()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.5))
                                        .background(.ultraThinMaterial.opacity(0.5))
                                        .clipShape(Capsule())
                                )
                            
                            Spacer()
                            
                            Text(formatTime(duration))
                                .font(.caption2)
                                .foregroundColor(.white)
                                .monospacedDigit()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.5))
                                        .background(.ultraThinMaterial.opacity(0.5))
                                        .clipShape(Capsule())
                                )
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 4)
                        
                        // Progress bar at the very bottom
                        VideoProgressBar(player: player, currentTime: $currentTime, duration: $duration)
                            .frame(height: 3)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .opacity(showControls ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: showControls)
                .allowsHitTesting(showControls)
            }
        }
        .aspectRatio(
            aspectRatio != nil ? CGFloat(aspectRatio!.width) / CGFloat(aspectRatio!.height) : 16/9,
            contentMode: .fit
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LinearGradient.voxSubtleGradient.opacity(0.2), lineWidth: 0.5)
        )
        .accessibilityLabel(alt ?? "Video")
        .onAppear {
            if autoPlayEnabled {
                setupPlayer()
            } else {
                isLoading = false
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        isLoading = true
        hasError = false
        errorMessage = ""
        
        print("VideoPlayerView: Attempting to load video from URL: \(videoURL)")
        
        // Create AVPlayerItem to monitor status
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Configure for HLS if needed
        if videoURL.pathExtension == "m3u8" {
            print("VideoPlayerView: Detected HLS stream (m3u8)")
            // HLS stream configuration
            player?.automaticallyWaitsToMinimizeStalling = true
        }
        
        // Set initial mute state
        player?.isMuted = muteByDefault
        
        // Observe player item status
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak playerItem] status in
                switch status {
                case .readyToPlay:
                    print("VideoPlayerView: Video ready to play")
                    isLoading = false
                    if autoPlayEnabled {
                        player?.play()
                        isPlaying = true
                    }
                    // Get duration when ready
                    Task {
                        if let duration = try? await player?.currentItem?.asset.load(.duration) {
                            self.duration = CMTimeGetSeconds(duration)
                        }
                    }
                case .failed:
                    print("VideoPlayerView: Video failed to load")
                    isLoading = false
                    hasError = true
                    if let error = playerItem?.error {
                        errorMessage = error.localizedDescription
                        print("VideoPlayerView: Error details: \(error)")
                        
                        // Check for specific error codes
                        if let nsError = error as NSError? {
                            print("VideoPlayerView: Error domain: \(nsError.domain), code: \(nsError.code)")
                            print("VideoPlayerView: Error userInfo: \(nsError.userInfo)")
                        }
                    }
                case .unknown:
                    print("VideoPlayerView: Player status unknown")
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Add time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
        }
        
        // Add observer for when video ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            // Loop video
            player?.seek(to: .zero)
            player?.play()
        }
        
        showControlsTemporarily()
    }
    
    @State private var cancellables = Set<AnyCancellable>()
    
    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    private func toggleMute() {
        player?.isMuted.toggle()
    }
    
    private func showControlsTemporarily() {
        showControls = true
        
        // Cancel previous hide task
        hideControlsTask?.cancel()
        
        // Hide controls after 3 seconds
        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if !Task.isCancelled {
                showControls = false
            }
        }
    }
    
    private func skipBackward() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = max(0, currentTime - 10)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
        showControlsTemporarily()
    }
    
    private func skipForward() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = min(duration, currentTime + 10)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
        showControlsTemporarily()
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Video progress bar component
struct VideoProgressBar: View {
    let player: AVPlayer?
    @Binding var currentTime: Double
    @Binding var duration: Double
    @State private var progress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color.white.opacity(0.3))
                
                // Progress
                Capsule()
                    .fill(LinearGradient.voxCoolGradient)
                    .frame(width: geometry.size.width * CGFloat(progress / max(duration, 1)))
            }
        }
        .onAppear {
            setupTimeObserver()
        }
    }
    
    private func setupTimeObserver() {
        guard let player = player else { return }
        
        // Get duration
        Task {
            if let durationTime = try? await player.currentItem?.asset.load(.duration) {
                duration = CMTimeGetSeconds(durationTime)
            }
        }
        
        // Observe progress
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let current = CMTimeGetSeconds(time)
            progress = current
            currentTime = current
        }
    }
}

// Preview
struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(
            videoURL: URL(string: "https://example.com/video.mp4")!,
            aspectRatio: AspectRatio(height: 9, width: 16),
            thumbnail: nil,
            alt: "Sample video"
        )
        .frame(height: 300)
        .padding()
    }
} 