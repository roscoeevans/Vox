import SwiftUI

struct ActionBar: View {
    let post: FeedViewPost
    let feedService: FeedServiceProtocol
    
    @Binding var isLiked: Bool
    @Binding var isReposted: Bool
    @Binding var likeCount: Int
    @Binding var repostCount: Int
    @Binding var replyCount: Int
    @Binding var likeURI: String?
    @Binding var repostURI: String?
    @Binding var showReplies: Bool
    
    @State private var isProcessingLike = false
    @State private var isProcessingRepost = false
    
    var body: some View {
        VStack(spacing: 2) {
            // Share button at the top
            Button(action: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                // Share functionality to be implemented later
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.voxBabyBlue, .voxCoral],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 2)
            
            ActionButton(
                icon: "arrow.2.squarepath",
                count: repostCount,
                isActive: isReposted,
                color: .voxSkyBlue,
                isProcessing: isProcessingRepost
            ) {
                Task {
                    await handleRepost()
                }
            }
            
            ActionButton(
                icon: "bubble.left",
                count: replyCount,
                isActive: false,
                color: .voxPeriwinkle,
                isProcessing: false
            ) {
                // Show replies sheet
                showReplies = true
            }
            
            ActionButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: likeCount,
                isActive: isLiked,
                color: .voxCoralRed,
                isProcessing: isProcessingLike
            ) {
                Task {
                    await handleLike()
                }
            }
        }
    }
    
    private func handleLike() async {
        guard !isProcessingLike else { return }
        
        isProcessingLike = true
        
        // Optimistic update
        let wasLiked = isLiked
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        
        do {
            if wasLiked {
                // Unlike
                if let uri = likeURI {
                    try await feedService.unlikePost(uri: uri)
                    likeURI = nil
                }
            } else {
                // Like
                let response = try await feedService.likePost(uri: post.post.uri, cid: post.post.cid)
                likeURI = response.uri
            }
        } catch {
            // Revert on error
            isLiked = wasLiked
            likeCount += wasLiked ? 1 : -1
            print("Error handling like: \(error)")
        }
        
        isProcessingLike = false
    }
    
    private func handleRepost() async {
        guard !isProcessingRepost else { return }
        
        isProcessingRepost = true
        
        // Optimistic update
        let wasReposted = isReposted
        isReposted.toggle()
        repostCount += isReposted ? 1 : -1
        
        do {
            if wasReposted {
                // Unrepost
                if let uri = repostURI {
                    try await feedService.unrepostPost(uri: uri)
                    repostURI = nil
                }
            } else {
                // Repost
                let response = try await feedService.repostPost(uri: post.post.uri, cid: post.post.cid)
                repostURI = response.uri
            }
        } catch {
            // Revert on error
            isReposted = wasReposted
            repostCount += wasReposted ? 1 : -1
            print("Error handling repost: \(error)")
        }
        
        isProcessingRepost = false
    }
}

// MARK: - Preview Support
#Preview {
    struct PreviewWrapper: View {
        @State private var isLiked = false
        @State private var isReposted = false
        @State private var likeCount = 42
        @State private var repostCount = 12
        @State private var replyCount = 5
        @State private var likeURI: String? = nil
        @State private var repostURI: String? = nil
        @State private var showReplies = false
        
        var body: some View {
            ActionBar(
                post: FeedViewPost.mockPost,
                feedService: MockFeedService(),
                isLiked: $isLiked,
                isReposted: $isReposted,
                likeCount: $likeCount,
                repostCount: $repostCount,
                replyCount: $replyCount,
                likeURI: $likeURI,
                repostURI: $repostURI,
                showReplies: $showReplies
            )
            .padding()
            .background(Color.voxBackground)
        }
    }
    
    return PreviewWrapper()
}



// MARK: - Mock Service
private class MockFeedService: FeedServiceProtocol {
    func getTimeline(cursor: String?) async throws -> TimelineResponse {
        // Not needed for ActionBar preview
        return TimelineResponse(cursor: nil, feed: [])
    }
    
    func likePost(uri: String, cid: String) async throws -> LikeResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return LikeResponse(uri: "at://did:plc:mock/app.bsky.feed.like/\(UUID().uuidString)", cid: cid)
    }
    
    func unlikePost(uri: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    func repostPost(uri: String, cid: String) async throws -> RepostResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return RepostResponse(uri: "at://did:plc:mock/app.bsky.feed.repost/\(UUID().uuidString)", cid: cid)
    }
    
    func unrepostPost(uri: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    func getPostThread(uri: String, depth: Int?, parentHeight: Int?) async throws -> PostThreadResponse {
        // Not needed for ActionBar preview - return minimal response
        let mockPost = FeedViewPost.mockPost
        let thread = ThreadViewPost(
            post: mockPost,
            parent: nil,
            replies: nil,
            viewer: nil,
            blocked: false,
            notFound: false
        )
        
        // Create a mock response by encoding and decoding
        let mockData: [String: Any] = [
            "thread": [
                "$type": "app.bsky.feed.defs#threadViewPost",
                "post": try! JSONSerialization.jsonObject(with: JSONEncoder().encode(mockPost)) as! [String: Any]
            ]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: mockData)
        return try! JSONDecoder().decode(PostThreadResponse.self, from: jsonData)
    }
    
    func createReply(text: String, parentUri: String, parentCid: String, rootUri: String, rootCid: String) async throws -> CreatePostResponse {
        // Not needed for ActionBar preview
        return CreatePostResponse(uri: "mock-uri", cid: "mock-cid")
    }
    
    func createPost(text: String, videoBlob: BSImage?, videoAspectRatio: AspectRatio?, videoAlt: String?) async throws -> CreatePostResponse {
        // Not needed for ActionBar preview
        return CreatePostResponse(uri: "mock-uri", cid: "mock-cid")
    }
} 
