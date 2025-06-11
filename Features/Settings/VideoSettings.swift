import SwiftUI

struct VideoSettings: View {
    @AppStorage("autoPlayVideos") private var autoPlayEnabled = true
    @AppStorage("videoQuality") private var videoQuality = "auto"
    @AppStorage("muteVideosByDefault") private var muteByDefault = true
    @AppStorage("showVideoSubtitles") private var showSubtitles = true
    @AppStorage("reduceMotion") private var reduceMotion = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Auto-play videos", isOn: $autoPlayEnabled)
                    .disabled(reduceMotion)
                
                Toggle("Mute videos by default", isOn: $muteByDefault)
                    .disabled(!autoPlayEnabled || reduceMotion)
                
                Toggle("Show subtitles when available", isOn: $showSubtitles)
            } header: {
                Text("Playback")
            } footer: {
                Text("Auto-play will start videos automatically when they appear in your feed. Videos will be muted by default to respect your environment.")
            }
            
            Section {
                Picker("Video Quality", selection: $videoQuality) {
                    Text("Auto (Recommended)").tag("auto")
                    Text("High Quality").tag("high")
                    Text("Data Saver").tag("low")
                }
                .pickerStyle(.menu)
            } header: {
                Text("Quality")
            } footer: {
                Text("Auto quality adjusts based on your network connection. Data Saver reduces video quality to save bandwidth.")
            }
            
            Section {
                Toggle("Reduce Motion", isOn: $reduceMotion)
            } header: {
                Text("Accessibility")
            } footer: {
                Text("Disables auto-play and reduces animations throughout the app. This overrides other video settings.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LinearGradient.voxCoolGradient)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Auto-play: \(autoPlayEnabled && !reduceMotion ? "On" : "Off")")
                                .font(.system(size: 14, weight: .medium))
                            Text("Videos will \(autoPlayEnabled && !reduceMotion ? "play automatically" : "require tap to play")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: muteByDefault ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LinearGradient.voxCoolGradient)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Default Sound: \(muteByDefault ? "Muted" : "On")")
                                .font(.system(size: 14, weight: .medium))
                            Text("Tap the speaker icon to \(muteByDefault ? "unmute" : "mute")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "captions.bubble.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LinearGradient.voxCoolGradient)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subtitles: \(showSubtitles ? "Visible" : "Hidden")")
                                .font(.system(size: 14, weight: .medium))
                            Text("When available from the video creator")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Current Settings")
            }
        }
        .navigationTitle("Video Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VideoSettings()
    }
} 