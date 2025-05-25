import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var appState: AppState
    @State private var posts: [FeedViewPost] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var cursor: String?
    
    private let feedService: FeedServiceProtocol
    
    init(feedService: FeedServiceProtocol) {
        self.feedService = feedService
        print("[FeedView] Initialized with feedService: \(feedService)")
    }
    
    var body: some View {
        NavigationStack {
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
                        LazyVStack(spacing: 8) {
                            ForEach(posts, id: \.post.uri) { post in
                                ThreadView(post: post)
                                    .onAppear {
                                        if post.post.uri == posts.last?.post.uri {
                                            Task {
                                                await loadMorePosts()
                                            }
                                        }
                                    }
                            }
                            
                            if isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await loadPosts()
                    }
                }
            }
            .navigationTitle("Feed")
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

#Preview {
    FeedView(feedService: MockBlueSkyFeedService())
        .environmentObject(AppState())
} 
