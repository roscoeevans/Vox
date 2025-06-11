import SwiftUI
import PhotosUI
import AVFoundation

struct ComposePostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ComposePostViewModel
    @State private var showingVideoPicker = false
    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var videoUploadProgress: Double = 0
    @State private var isUploadingVideo = false
    @State private var showingVideoError = false
    @State private var videoErrorMessage = ""
    @FocusState private var isTextFieldFocused: Bool
    
    init(feedService: FeedServiceProtocol, authService: BlueSkyAuthService) {
        _viewModel = StateObject(wrappedValue: ComposePostViewModel(
            feedService: feedService,
            authService: authService
        ))
    }
    
    private var textEditor: some View {
        TextEditor(text: $viewModel.postText)
            .font(.system(size: 16))
            .foregroundColor(.voxText)
            .padding(.horizontal, 4)
            .focused($isTextFieldFocused)
    }
    
    private var placeholderOverlay: some View {
        Group {
            if viewModel.postText.isEmpty {
                Text("What's on your mind?")
                    .font(.system(size: 16))
                    .foregroundColor(.voxText.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Post text editor
                VStack(alignment: .leading, spacing: 12) {
                    textEditor
                        .overlay(placeholderOverlay, alignment: .topLeading)
                    
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(viewModel.postText.count)/300")
                            .font(.caption)
                            .foregroundColor(viewModel.postText.count > 300 ? .voxCoralRed : .voxText.opacity(0.6))
                    }
                    .padding(.horizontal)
                    
                    // Video preview if attached
                    if let videoData = viewModel.attachedVideo {
                        VideoAttachmentPreview(
                            videoData: videoData,
                            onRemove: {
                                viewModel.removeVideo()
                            }
                        )
                        .padding(.horizontal)
                    }
                    
                    // Upload progress
                    if isUploadingVideo {
                        VStack(spacing: 8) {
                            Text("Uploading video...")
                                .font(.caption)
                                .foregroundColor(.voxText.opacity(0.6))
                            
                            ProgressView(value: videoUploadProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .voxSkyBlue))
                                .frame(height: 4)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                Spacer()
                
                // Bottom toolbar
                VStack(spacing: 0) {
                    Divider()
                        .background(LinearGradient.voxSubtleGradient.opacity(0.3))
                    
                    HStack(spacing: 24) {
                        // Video attachment button
                        Button(action: {
                            showingVideoPicker = true
                        }) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundStyle(viewModel.attachedVideo != nil ? LinearGradient.voxCoolGradient : LinearGradient(colors: [.voxText.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        .disabled(isUploadingVideo || viewModel.attachedVideo != nil)
                        
                        // Image attachment button (placeholder)
                        Button(action: {
                            // TODO: Implement image picker
                        }) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.voxText.opacity(0.6))
                        }
                        .disabled(isUploadingVideo || viewModel.attachedVideo != nil)
                        
                        Spacer()
                        
                        // Post button
                        Button(action: {
                            Task {
                                await viewModel.createPost()
                                dismiss()
                            }
                        }) {
                            Text("Post")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(viewModel.canPost ? LinearGradient.voxCoolGradient : LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                        }
                        .disabled(!viewModel.canPost || viewModel.isPosting)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .photosPicker(
            isPresented: $showingVideoPicker,
            selection: $selectedVideoItem,
            matching: .videos
        )
        .onChange(of: selectedVideoItem) { newItem in
            Task {
                await handleVideoSelection(newItem)
            }
        }
        .alert("Video Error", isPresented: $showingVideoError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(videoErrorMessage)
        }
    }
    
    private func handleVideoSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isUploadingVideo = true
        videoUploadProgress = 0
        
        do {
            // Load video data
            guard let movie = try await item.loadTransferable(type: Movie.self) else {
                throw VideoUploadError.invalidFormat
            }
            
            // Upload video
            let videoBlob = try await viewModel.uploadVideo(
                fileURL: movie.url,
                onProgress: { progress in
                    Task { @MainActor in
                        videoUploadProgress = progress
                    }
                }
            )
            
            // Get video metadata
            let asset = AVAsset(url: movie.url)
            let duration = try await asset.load(.duration)
            let tracks = try await asset.load(.tracks)
            
            var aspectRatio: AspectRatio?
            if let videoTrack = tracks.first(where: { $0.mediaType == .video }) {
                let size = try await videoTrack.load(.naturalSize)
                aspectRatio = AspectRatio(
                    height: Int(size.height),
                    width: Int(size.width)
                )
            }
            
            await MainActor.run {
                viewModel.attachedVideo = VideoAttachment(
                    blob: videoBlob,
                    aspectRatio: aspectRatio,
                    duration: CMTimeGetSeconds(duration),
                    localURL: movie.url
                )
                isUploadingVideo = false
            }
        } catch {
            await MainActor.run {
                isUploadingVideo = false
                videoErrorMessage = error.localizedDescription
                showingVideoError = true
            }
        }
    }
}

// Video attachment data model
struct VideoAttachment {
    let blob: BSImage
    let aspectRatio: AspectRatio?
    let duration: TimeInterval
    let localURL: URL
}

// Video attachment preview component
struct VideoAttachmentPreview: View {
    let videoData: VideoAttachment
    let onRemove: () -> Void
    @State private var thumbnail: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Video thumbnail
            Group {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(LinearGradient.voxSubtleGradient.opacity(0.3))
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                // Play icon overlay
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(LinearGradient.voxCoolGradient)
                }
            )
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white, Color.black.opacity(0.6))
            }
            .padding(8)
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        Task {
            let asset = AVAsset(url: videoData.localURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            do {
                let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                await MainActor.run {
                    thumbnail = UIImage(cgImage: cgImage)
                }
            } catch {
                print("Failed to generate thumbnail: \(error)")
            }
        }
    }
}

// Movie transferable for PhotosPicker
struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie_\(UUID().uuidString).mov")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self(url: copy)
        }
    }
}

// View model
@MainActor
class ComposePostViewModel: ObservableObject {
    @Published var postText = ""
    @Published var attachedVideo: VideoAttachment?
    @Published var isPosting = false
    
    private let feedService: FeedServiceProtocol
    private let authService: BlueSkyAuthService
    private let videoUploadService: VideoUploadService
    
    init(feedService: FeedServiceProtocol, authService: BlueSkyAuthService) {
        self.feedService = feedService
        self.authService = authService
        self.videoUploadService = VideoUploadService(authService: authService)
    }
    
    var canPost: Bool {
        !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        postText.count <= 300 &&
        !isPosting
    }
    
    func uploadVideo(fileURL: URL, onProgress: @escaping (Double) -> Void) async throws -> BSImage {
        return try await videoUploadService.uploadVideo(
            fileURL: fileURL,
            onProgress: onProgress
        )
    }
    
    func createPost() async {
        guard canPost else { return }
        
        isPosting = true
        
        do {
            _ = try await feedService.createPost(
                text: postText,
                videoBlob: attachedVideo?.blob,
                videoAspectRatio: attachedVideo?.aspectRatio,
                videoAlt: nil
            )
            
            // Clear form
            postText = ""
            attachedVideo = nil
        } catch {
            print("Failed to create post: \(error)")
            // TODO: Show error alert
        }
        
        isPosting = false
    }
    
    func removeVideo() {
        attachedVideo = nil
        // Clean up temporary file
        if let url = attachedVideo?.localURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

#Preview {
    ComposePostView(
        feedService: MockBlueSkyFeedService(),
        authService: BlueSkyAuthService()
    )
} 