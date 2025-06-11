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
            ),
            // Add a post with a quote
            FeedViewPost(
                post: BSPost(
                    uri: "at://did:plc:mock4/app.bsky.feed.post/4",
                    cid: "mock-cid-4",
                    author: BSAuthor(
                        did: "did:plc:mock4",
                        handle: "dave.bsky.social",
                        displayName: "Dave Miller",
                        avatar: nil,
                        associated: nil,
                        viewer: nil,
                        labels: nil,
                        createdAt: "2024-03-20T09:00:00Z"
                    ),
                    record: BSPostRecord(
                        type: "app.bsky.feed.post",
                        text: "This is exactly what I was thinking! Great point about the importance of user experience.",
                        createdAt: "2024-03-20T09:00:00Z",
                        embed: BSEmbed(
                            type: "app.bsky.embed.record",
                            record: BSEmbedRecord(
                                type: "app.bsky.embed.record",
                                record: BSEmbedRecordView(
                                    type: "app.bsky.embed.record",
                                    uri: "at://did:plc:quoted/app.bsky.feed.post/quoted",
                                    cid: "quoted-cid",
                                    post: BSPost(
                                        uri: "at://did:plc:quoted/app.bsky.feed.post/quoted",
                                        cid: "quoted-cid",
                                        author: BSAuthor(
                                            did: "did:plc:quoted",
                                            handle: "quoteduser.bsky.social",
                                            displayName: "Quoted User",
                                            avatar: nil,
                                            associated: nil,
                                            viewer: nil,
                                            labels: nil,
                                            createdAt: "2024-03-19T10:00:00Z"
                                        ),
                                        record: BSPostRecord(
                                            type: "app.bsky.feed.post",
                                            text: "User experience should always be the top priority when building apps. If users can't figure out how to use your app, it doesn't matter how powerful it is.",
                                            createdAt: "2024-03-19T10:00:00Z",
                                            embed: nil,
                                            reply: nil,
                                            langs: ["en"],
                                            facets: nil
                                        ),
                                        replyCount: 2,
                                        repostCount: 5,
                                        likeCount: 15,
                                        quoteCount: 1,
                                        indexedAt: "2024-03-19T10:00:00Z",
                                        viewer: nil,
                                        labels: nil,
                                        embed: nil
                                    ),
                                    value: BSPostRecord(
                                        type: "app.bsky.feed.post",
                                        text: "User experience should always be the top priority when building apps. If users can't figure out how to use your app, it doesn't matter how powerful it is.",
                                        createdAt: "2024-03-19T10:00:00Z",
                                        embed: nil,
                                        reply: nil,
                                        langs: ["en"],
                                        facets: nil
                                    ),
                                    labels: nil,
                                    likeCount: 15,
                                    replyCount: 2,
                                    repostCount: 5,
                                    quoteCount: 1,
                                    indexedAt: "2024-03-19T10:00:00Z",
                                    embeds: nil,
                                    viewer: nil
                                ),
                                media: nil
                            ),
                            media: nil,
                            images: nil,
                            external: nil
                        ),
                        reply: nil,
                        langs: ["en"],
                        facets: nil
                    ),
                    replyCount: 1,
                    repostCount: 3,
                    likeCount: 12,
                    quoteCount: 0,
                    indexedAt: "2024-03-20T09:00:00Z",
                    viewer: nil,
                    labels: nil,
                    embed: BSEmbed(
                        type: "app.bsky.embed.record",
                        record: BSEmbedRecord(
                            type: "app.bsky.embed.record",
                            record: BSEmbedRecordView(
                                type: "app.bsky.embed.record",
                                uri: "at://did:plc:quoted/app.bsky.feed.post/quoted",
                                cid: "quoted-cid",
                                post: BSPost(
                                    uri: "at://did:plc:quoted/app.bsky.feed.post/quoted",
                                    cid: "quoted-cid",
                                    author: BSAuthor(
                                        did: "did:plc:quoted",
                                        handle: "quoteduser.bsky.social",
                                        displayName: "Quoted User",
                                        avatar: nil,
                                        associated: nil,
                                        viewer: nil,
                                        labels: nil,
                                        createdAt: "2024-03-19T10:00:00Z"
                                    ),
                                    record: BSPostRecord(
                                        type: "app.bsky.feed.post",
                                        text: "User experience should always be the top priority when building apps. If users can't figure out how to use your app, it doesn't matter how powerful it is.",
                                        createdAt: "2024-03-19T10:00:00Z",
                                        embed: nil,
                                        reply: nil,
                                        langs: ["en"],
                                        facets: nil
                                    ),
                                    replyCount: 2,
                                    repostCount: 5,
                                    likeCount: 15,
                                    quoteCount: 1,
                                    indexedAt: "2024-03-19T10:00:00Z",
                                    viewer: nil,
                                    labels: nil,
                                    embed: nil
                                ),
                                value: BSPostRecord(
                                    type: "app.bsky.feed.post",
                                    text: "User experience should always be the top priority when building apps. If users can't figure out how to use your app, it doesn't matter how powerful it is.",
                                    createdAt: "2024-03-19T10:00:00Z",
                                    embed: nil,
                                    reply: nil,
                                    langs: ["en"],
                                    facets: nil
                                ),
                                labels: nil,
                                likeCount: 15,
                                replyCount: 2,
                                repostCount: 5,
                                quoteCount: 1,
                                indexedAt: "2024-03-19T10:00:00Z",
                                embeds: nil,
                                viewer: nil
                            ),
                            media: nil
                        ),
                        media: nil,
                        images: nil,
                        external: nil
                    )
                ),
                reply: nil,
                reason: nil,
                embed: BSEmbed(
                    type: "app.bsky.embed.record",
                    record: BSEmbedRecord(
                        type: "app.bsky.embed.record",
                        record: BSEmbedRecordView(
                            type: "app.bsky.embed.record",
                            uri: "at://did:plc:quoted/app.bsky.feed.post/quoted",
                            cid: "quoted-cid",
                            post: BSPost(
                                uri: "at://did:plc:quoted/app.bsky.feed.post/quoted",
                                cid: "quoted-cid",
                                author: BSAuthor(
                                    did: "did:plc:quoted",
                                    handle: "quoteduser.bsky.social",
                                    displayName: "Quoted User",
                                    avatar: nil,
                                    associated: nil,
                                    viewer: nil,
                                    labels: nil,
                                    createdAt: "2024-03-19T10:00:00Z"
                                ),
                                record: BSPostRecord(
                                    type: "app.bsky.feed.post",
                                    text: "User experience should always be the top priority when building apps. If users can't figure out how to use your app, it doesn't matter how powerful it is.",
                                    createdAt: "2024-03-19T10:00:00Z",
                                    embed: nil,
                                    reply: nil,
                                    langs: ["en"],
                                    facets: nil
                                ),
                                replyCount: 2,
                                repostCount: 5,
                                likeCount: 15,
                                quoteCount: 1,
                                indexedAt: "2024-03-19T10:00:00Z",
                                viewer: nil,
                                labels: nil,
                                embed: nil
                            ),
                            value: BSPostRecord(
                                type: "app.bsky.feed.post",
                                text: "User experience should always be the top priority when building apps. If users can't figure out how to use your app, it doesn't matter how powerful it is.",
                                createdAt: "2024-03-19T10:00:00Z",
                                embed: nil,
                                reply: nil,
                                langs: ["en"],
                                facets: nil
                            ),
                            labels: nil,
                            likeCount: 15,
                            replyCount: 2,
                            repostCount: 5,
                            quoteCount: 1,
                            indexedAt: "2024-03-19T10:00:00Z",
                            embeds: nil,
                            viewer: nil
                        ),
                        media: nil
                    ),
                    media: nil,
                    images: nil,
                    external: nil
                ),
                viewer: nil,
                labels: nil
            )
        ]
    }
    
    // MARK: - Feed Methods
    func getTimeline(cursor: String? = nil) async throws -> TimelineResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return TimelineResponse(
            cursor: "next-cursor",
            feed: mockPosts
        )
    }
    
    func likePost(uri: String, cid: String) async throws -> LikeResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Generate a mock like URI
        let likeURI = "at://\(UUID().uuidString)/app.bsky.feed.like/\(UUID().uuidString)"
        return LikeResponse(uri: likeURI, cid: cid)
    }
    
    func unlikePost(uri: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        // Mock successful unlike
    }
    
    func repostPost(uri: String, cid: String) async throws -> RepostResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Generate a mock repost URI
        let repostURI = "at://\(UUID().uuidString)/app.bsky.feed.repost/\(UUID().uuidString)"
        return RepostResponse(uri: repostURI, cid: cid)
    }
    
    func unrepostPost(uri: String) async throws {
        // No-op for mock
    }
    
    func getPostThread(uri: String, depth: Int? = nil, parentHeight: Int? = nil) async throws -> PostThreadResponse {
        // Create a mock thread response
        let mockPost = mockPosts.first ?? FeedViewPost(
            post: BSPost(
                uri: uri,
                cid: "mock-cid",
                author: BSAuthor(
                    did: "did:plc:mock",
                    handle: "mockuser.bsky.social",
                    displayName: "Mock User",
                    avatar: nil,
                    associated: nil,
                    viewer: nil,
                    labels: nil,
                    createdAt: "2024-01-01T00:00:00Z"
                ),
                record: BSPostRecord(
                    type: "app.bsky.feed.post",
                    text: "This is the original post",
                    createdAt: "2024-01-01T00:00:00Z",
                    embed: nil,
                    reply: nil,
                    langs: ["en"],
                    facets: nil
                ),
                replyCount: 3,
                repostCount: 0,
                likeCount: 5,
                quoteCount: 0,
                indexedAt: "2024-01-01T00:00:00Z",
                viewer: BSViewer(),
                labels: nil,
                embed: nil
            ),
            reply: nil,
            reason: nil,
            embed: nil,
            viewer: nil,
            labels: nil
        )
        
        // Create mock replies
        let mockReplies = [
            ThreadViewPost(
                post: FeedViewPost(
                    post: BSPost(
                        uri: "at://did:plc:reply1/app.bsky.feed.post/1",
                        cid: "reply-cid-1",
                        author: BSAuthor(
                            did: "did:plc:reply1",
                            handle: "replyuser1.bsky.social",
                            displayName: "Reply User 1",
                            avatar: nil,
                            associated: nil,
                            viewer: nil,
                            labels: nil,
                            createdAt: "2024-01-01T01:00:00Z"
                        ),
                        record: BSPostRecord(
                            type: "app.bsky.feed.post",
                            text: "Great post! I totally agree with this.",
                            createdAt: "2024-01-01T01:00:00Z",
                            embed: nil,
                            reply: nil,
                            langs: ["en"],
                            facets: nil
                        ),
                        replyCount: 1,
                        repostCount: 0,
                        likeCount: 2,
                        quoteCount: 0,
                        indexedAt: "2024-01-01T01:00:00Z",
                        viewer: BSViewer(),
                        labels: nil,
                        embed: nil
                    ),
                    reply: nil,
                    reason: nil,
                    embed: nil,
                    viewer: nil,
                    labels: nil
                ),
                parent: nil,
                replies: nil,
                viewer: nil,
                blocked: false,
                notFound: false
            ),
            ThreadViewPost(
                post: FeedViewPost(
                    post: BSPost(
                        uri: "at://did:plc:reply2/app.bsky.feed.post/2",
                        cid: "reply-cid-2",
                        author: BSAuthor(
                            did: "did:plc:reply2",
                            handle: "replyuser2.bsky.social",
                            displayName: "Reply User 2",
                            avatar: nil,
                            associated: nil,
                            viewer: nil,
                            labels: nil,
                            createdAt: "2024-01-01T02:00:00Z"
                        ),
                        record: BSPostRecord(
                            type: "app.bsky.feed.post",
                            text: "Interesting perspective! What about the other side of this?",
                            createdAt: "2024-01-01T02:00:00Z",
                            embed: nil,
                            reply: nil,
                            langs: ["en"],
                            facets: nil
                        ),
                        replyCount: 0,
                        repostCount: 0,
                        likeCount: 1,
                        quoteCount: 0,
                        indexedAt: "2024-01-01T02:00:00Z",
                        viewer: BSViewer(),
                        labels: nil,
                        embed: nil
                    ),
                    reply: nil,
                    reason: nil,
                    embed: nil,
                    viewer: nil,
                    labels: nil
                ),
                parent: nil,
                replies: nil,
                viewer: nil,
                blocked: false,
                notFound: false
            )
        ]
        
        let thread = ThreadViewPost(
            post: mockPost,
            parent: nil,
            replies: mockReplies,
            viewer: nil,
            blocked: false,
            notFound: false
        )
        
        // Create a mock response by encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        // First encode the thread
        let threadData = try! encoder.encode(thread)
        let threadJSON = try! JSONSerialization.jsonObject(with: threadData) as! [String: Any]
        
        // Wrap it in the response structure
        let mockData: [String: Any] = ["thread": threadJSON]
        
        // Convert to JSON data and decode as PostThreadResponse
        let jsonData = try! JSONSerialization.data(withJSONObject: mockData)
        return try! decoder.decode(PostThreadResponse.self, from: jsonData)
    }
    
    func createReply(text: String, parentUri: String, parentCid: String, rootUri: String, rootCid: String) async throws -> CreatePostResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Generate a mock reply URI
        let replyURI = "at://\(UUID().uuidString)/app.bsky.feed.post/\(UUID().uuidString)"
        return CreatePostResponse(uri: replyURI, cid: "mock-reply-cid")
    }
    
    func createPost(text: String, videoBlob: BSImage? = nil, videoAspectRatio: AspectRatio? = nil, videoAlt: String? = nil) async throws -> CreatePostResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Generate a mock post URI
        let postURI = "at://\(UUID().uuidString)/app.bsky.feed.post/\(UUID().uuidString)"
        return CreatePostResponse(uri: postURI, cid: "mock-post-cid")
    }
} 