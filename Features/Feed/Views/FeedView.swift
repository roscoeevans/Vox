import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var appState: AppState
    @State private var posts: [FeedViewPost] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var cursor: String?
    @State private var selectedMedia: (post: FeedViewPost, mediaID: String)? = nil
    @Namespace private var imageAnimationNamespace
    
    private let feedService: FeedServiceProtocol
    
    init(feedService: FeedServiceProtocol) {
        self.feedService = feedService
        print("[FeedView] Initialized with feedService: \(feedService)")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                Group {
                    if isLoading && posts.isEmpty {
                        ProgressView()
                    } else if let error = error {
                        VStack(spacing: 16) {
                            Text(error.localizedDescription)
                                .foregroundStyle(.red)
                            
                            Button("Try Again") {
                                Task {
                                    await loadPosts()
                                }
                            }
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(posts, id: \.post.uri) { post in
                                    PostView(post: post, feedService: feedService)
                                        .onAppear {
                                            if post.post.uri == posts.last?.post.uri {
                                                Task {
                                                    await loadMorePosts()
                                                }
                                            }
                                        }
                                    
                                    Rectangle()
                                        .fill(Color.voxSeparator)
                                        .frame(height: FeedSpacing.separatorHeight)
                                        .padding(.vertical, FeedSpacing.separatorVerticalPadding)
                                }
                                
                                if isLoading {
                                    ProgressView()
                                        .padding()
                                }
                            }
                        }
                        .refreshable {
                            await loadPosts()
                        }
                    }
                }
                .navigationTitle("Feed")
                .voxNavigationTitleFont()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                await loadPosts()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                
                // Full-screen overlay for selected image
                if let selectedMedia = selectedMedia {
                    let post = selectedMedia.post
                    let mediaID = selectedMedia.mediaID
                    if let images = post.post.embed?.images {
                        // Find the image that matches our mediaID
                        let matchingImage = images.prefix(4).enumerated().first { idx, img in
                            if let urlString = img.fullsize ?? img.thumb {
                                let uniqueId = "img-\(idx)-\(post.post.uri)-\(urlString.hashValue)"
                                return uniqueId == mediaID
                            }
                            return false
                        }
                        
                        if let (_, image) = matchingImage,
                           let urlString = image.fullsize ?? image.thumb,
                           let url = URL(string: urlString) {
                            Color.clear
                                .background(
                                    FullscreenImageView(
                                        imageURL: url,
                                        namespace: imageAnimationNamespace,
                                        id: mediaID,
                                        isPresented: Binding(
                                            get: { self.selectedMedia != nil },
                                            set: { if !$0 { self.selectedMedia = nil } }
                                        )
                                    )
                                )
                                .ignoresSafeArea()
                                .transition(.identity)
                        }
                    }
                }
            }
        }
        .task {
            await loadPosts()
        }
    }
    
    private func loadPosts() async {
        print("[FeedView] Loading posts...")
        isLoading = true
        error = nil
        cursor = nil
        
        do {
            let response = try await feedService.getTimeline(cursor: nil)
            await MainActor.run {
                posts = response.feed
                cursor = response.cursor
            }
            print("[FeedView] Loaded \(response.feed.count) posts. Cursor: \(String(describing: response.cursor))")
        } catch {
            self.error = error
            print("[FeedView] Error loading posts: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func loadMorePosts() async {
        guard let cursor = cursor, !isLoading else { return }
        print("[FeedView] Loading more posts with cursor: \(cursor)")
        isLoading = true
        
        do {
            let response = try await feedService.getTimeline(cursor: cursor)
            await MainActor.run {
                posts.append(contentsOf: response.feed)
                self.cursor = response.cursor
            }
            print("[FeedView] Loaded more posts: \(response.feed.count) new posts. New cursor: \(String(describing: response.cursor))")
        } catch {
            self.error = error
            print("[FeedView] Error loading more posts: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

// MARK: - Fullscreen Image View
private struct FullscreenImageView: View {
    let imageURL: URL
    let namespace: Namespace.ID
    let id: String
    @Binding var isPresented: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    private let dismissThreshold: CGFloat = 100
    private let dismissVelocityThreshold: CGFloat = 500

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
                .opacity(1.0 - abs(dragOffset.height) / CGFloat(500))
                .onTapGesture {
                    if scale == 1.0 {
                        isPresented = false
                    }
                }
            
            // Image with gestures
            GeometryReader { geometry in
                CachedAsyncImage(url: imageURL, contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(scale)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .offset(dragOffset)
                    .matchedGeometryEffect(
                        id: id,
                        in: namespace,
                        properties: .frame,
                        anchor: .center,
                        isSource: false
                    )
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if scale == 1.0 {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        let shouldDismiss = abs(value.translation.height) > dismissThreshold ||
                                          abs(value.predictedEndTranslation.height) > dismissVelocityThreshold
                        
                        if shouldDismiss && scale == 1.0 {
                            isPresented = false
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = .zero
                            }
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { value in
                        lastScale = scale
                        if scale < 1.0 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                scale = 1.0
                                lastScale = 1.0
                            }
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            )
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                     Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
            .opacity(dragOffset == .zero ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: dragOffset)
        }
        .statusBarHidden(true)
    }
}

#Preview {
    FeedView(feedService: MockBlueSkyFeedService())
        .environmentObject(AppState())
} 
