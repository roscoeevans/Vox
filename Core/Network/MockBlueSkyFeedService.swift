import Foundation

actor MockBlueSkyFeedService: FeedServiceProtocol {
    // MARK: - Properties
    private let mockPosts: [FeedViewPost]
    
    // MARK: - Initialization
    init() {
        // Create mock posts with realistic data
        self.mockPosts = [
            FeedViewPost(
                post: BSPost(
                    uri: "at://did:plc:mock1/app.bsky.feed.post/1",
                    cid: "mock-cid-1",
                    author: BSAuthor(
                        did: "did:plc:mock1",
                        handle: "alice.bsky.social",
                        displayName: "Alice Smith",
                        avatar: nil,
                        associated: nil,
                        viewer: nil,
                        labels: nil,
                        createdAt: "2024-03-20T12:00:00Z"
                    ),
                    record: BSPostRecord(
                        type: "app.bsky.feed.post",
                        text: "Just launched my new app! 🚀\n\nExcited to share what I've been working on. It's been a long journey but worth every moment. #iOSDev #SwiftUI",
                        createdAt: "2024-03-20T12:00:00Z",
                        embed: nil,
                        reply: nil,
                        langs: ["en"],
                        facets: nil
                    ),
                    replyCount: 5,
                    repostCount: 12,
                    likeCount: 42,
                    quoteCount: 3,
                    indexedAt: "2024-03-20T12:00:00Z",
                    viewer: nil,
                    labels: nil,
                    embed: nil
                ),
                reply: nil,
                reason: nil,
                embed: nil,
                viewer: nil,
                labels: nil
            ),
            FeedViewPost(
                post: BSPost(
                    uri: "at://did:plc:mock2/app.bsky.feed.post/2",
                    cid: "mock-cid-2",
                    author: BSAuthor(
                        did: "did:plc:mock2",
                        handle: "bob.bsky.social",
                        displayName: "Bob Johnson",
                        avatar: nil,
                        associated: nil,
                        viewer: nil,
                        labels: nil,
                        createdAt: "2024-03-20T11:00:00Z"
                    ),
                    record: BSPostRecord(
                        type: "app.bsky.feed.post",
                        text: "Beautiful day for coding! ☀️\n\nWorking on some exciting new features. The weather is perfect for a productive day. #CodingLife #Developer",
                        createdAt: "2024-03-20T11:00:00Z",
                        embed: nil,
                        reply: nil,
                        langs: ["en"],
                        facets: nil
                    ),
                    replyCount: 3,
                    repostCount: 8,
                    likeCount: 24,
                    quoteCount: 1,
                    indexedAt: "2024-03-20T11:00:00Z",
                    viewer: nil,
                    labels: nil,
                    embed: nil
                ),
                reply: nil,
                reason: nil,
                embed: nil,
                viewer: nil,
                labels: nil
            ),
            FeedViewPost(
                post: BSPost(
                    uri: "at://did:plc:mock3/app.bsky.feed.post/3",
                    cid: "mock-cid-3",
                    author: BSAuthor(
                        did: "did:plc:mock3",
                        handle: "carol.bsky.social",
                        displayName: "Carol Williams",
                        avatar: nil,
                        associated: nil,
                        viewer: nil,
                        labels: nil,
                        createdAt: "2024-03-20T10:00:00Z"
                    ),
                    record: BSPostRecord(
                        type: "app.bsky.feed.post",
                        text: "Just finished reading 'The Midnight Library' by Matt Haig. What an incredible journey through infinite possibilities! The way it explores regret, choice, and the beauty of ordinary life really resonated with me. Highly recommend this thought-provoking read. #BookReview #TheMidnightLibrary",
                        createdAt: "2024-03-20T10:00:00Z",
                        embed: nil,
                        reply: nil,
                        langs: ["en"],
                        facets: nil
                    ),
                    replyCount: 7,
                    repostCount: 15,
                    likeCount: 89,
                    quoteCount: 4,
                    indexedAt: "2024-03-20T10:00:00Z",
                    viewer: nil,
                    labels: nil,
                    embed: nil
                ),
                reply: nil,
                reason: nil,
                embed: nil,
                viewer: nil,
                labels: nil
            )
        ]
    }
    
    // MARK: - Feed Methods
    func getTimeline(cursor: String? = nil) async throws -> TimelineResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // If cursor is nil, return first page
        if cursor == nil {
            return TimelineResponse(
                cursor: "mock-cursor-1",
                feed: Array(mockPosts.prefix(2))
            )
        }
        
        // If cursor is "mock-cursor-1", return second page
        if cursor == "mock-cursor-1" {
            return TimelineResponse(
                cursor: nil,
                feed: Array(mockPosts.suffix(1))
            )
        }
        
        // If cursor is anything else, return empty response
        return TimelineResponse(
            cursor: nil,
            feed: []
        )
    }
} 