import SwiftUI
import ATProtoKit
import UIKit

// Import subcomponents
// (Assume module or file imports as needed for Swift)

// RoundedCorner shape moved to UI/Styles/Shapes.swift as SelectiveRoundedCorners

// MARK: - Main Component
struct PostView: View {
    let post: FeedViewPost
    let feedService: FeedServiceProtocol
    
    @State private var isLiked: Bool
    @State private var isReposted: Bool
    @State private var likeCount: Int
    @State private var repostCount: Int
    @State private var replyCount: Int
    @State private var likeURI: String?
    @State private var repostURI: String?
    @State private var showReplies = false
    
    // Swipe gesture states
    @State private var swipeOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var hasTriggeredLike = false
    @State private var hasTriggeredDislike = false
    @State private var isPressing = false
    
    // Persistent swipe states
    @State private var hasSwipedRight = false
    @State private var hasSwipedLeft = false
    
    // Swipe thresholds
    private let swipeThreshold: CGFloat = 100
    private let maxSwipeDistance: CGFloat = 150
    private let minimumDragDistance: CGFloat = 10
    
    init(post: FeedViewPost, feedService: FeedServiceProtocol) {
        self.post = post
        self.feedService = feedService
        
        // Initialize state from viewer data
        _isLiked = State(initialValue: post.post.viewer?.like != nil)
        _isReposted = State(initialValue: post.post.viewer?.repost != nil)
        _likeCount = State(initialValue: post.post.likeCount)
        _repostCount = State(initialValue: post.post.repostCount)
        _replyCount = State(initialValue: post.post.replyCount)
        _likeURI = State(initialValue: post.post.viewer?.like)
        _repostURI = State(initialValue: post.post.viewer?.repost)
    }
    
    private var backgroundColor: Color {
        if hasSwipedRight {
            return Color.green.opacity(0.3)
        } else if hasSwipedLeft {
            return Color.red.opacity(0.3)
        } else if swipeOffset > swipeThreshold {
            return Color.green.opacity(0.3)
        } else if swipeOffset < -swipeThreshold {
            return Color.red.opacity(0.3)
        } else {
            return Color.gray.opacity(0.175)
        }
    }
    
    private var swipeProgress: CGFloat {
        if swipeOffset > 0 {
            return min(swipeOffset / swipeThreshold, 1.0)
        } else {
            return max(swipeOffset / swipeThreshold, -1.0)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Main content area
            VStack(alignment: .leading, spacing: 8) {
                // Profile header
                HStack(alignment: .center, spacing: 8) {
                    ProfileImage(avatarURLString: post.author.avatar)
                    AuthorHandleView(author: post.author)
                    Text(post.post.record.createdAt.timeAgoFromISO8601())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                // Post content
                PostContent(post: post)

            }
            .feedPostPadding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ContentHeightPreferenceKey.self, value: geometry.size.height)
                }
            )
            .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                // This gives us the actual height of the content
            }
            
            // Action buttons column
            VStack {
                Spacer(minLength: 0)
                ActionBar(
                    post: post,
                    feedService: feedService,
                    isLiked: $isLiked,
                    isReposted: $isReposted,
                    likeCount: $likeCount,
                    repostCount: $repostCount,
                    replyCount: $replyCount,
                    likeURI: $likeURI,
                    repostURI: $repostURI,
                    showReplies: $showReplies
                )
            }
            .feedActionBarPadding()
         // Smaller padding on the left to give more room for text
        }
        .fixedSize(horizontal: false, vertical: true) // This makes the view only take up the space it needs vertically
        .overlay(
            // Like indicator
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .opacity(swipeOffset > swipeThreshold ? Double(swipeProgress) : 0)
                    .scaleEffect(swipeOffset > swipeThreshold ? 1.0 + (swipeProgress * 0.2) : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: swipeOffset)
                    .padding(.leading, 20)
                
                Spacer()
                
                // Dislike indicator
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .opacity(swipeOffset < -swipeThreshold ? Double(abs(swipeProgress)) : 0)
                    .scaleEffect(swipeOffset < -swipeThreshold ? 1.0 + (abs(swipeProgress) * 0.2) : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: swipeOffset)
                    .padding(.trailing, 20)
            }
        )
        .offset(x: swipeOffset)
        .simultaneousGesture(
            DragGesture(minimumDistance: 50)
                .onChanged { value in
                    // Only process horizontal swipes
                    if abs(value.translation.width) > abs(value.translation.height) * 1.5 {
                        isDragging = true
                        let translation = value.translation.width
                        
                        // Apply resistance at the edges
                        if abs(translation) > maxSwipeDistance {
                            let overflow = abs(translation) - maxSwipeDistance
                            let resistance = 1 - (overflow / (overflow + 100))
                            swipeOffset = translation > 0 
                                ? maxSwipeDistance + (overflow * resistance * 0.3)
                                : -maxSwipeDistance - (overflow * resistance * 0.3)
                        } else {
                            swipeOffset = translation
                        }
                        
                        // Check if we've crossed the threshold for like
                        if swipeOffset > swipeThreshold && !hasTriggeredLike {
                            hasTriggeredLike = true
                            hasTriggeredDislike = false
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                        
                        // Check if we've crossed the threshold for dislike
                        if swipeOffset < -swipeThreshold && !hasTriggeredDislike {
                            hasTriggeredDislike = true
                            hasTriggeredLike = false
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                        
                        // Reset triggers if we're back in the neutral zone
                        if abs(swipeOffset) < swipeThreshold {
                            hasTriggeredLike = false
                            hasTriggeredDislike = false
                        }
                    }
                }
                .onEnded { value in
                    if isDragging {
                        isDragging = false
                        
                        // Determine final action based on position
                        if swipeOffset > swipeThreshold {
                            // Right swipe - algorithm feedback (not actual like)
                            hasSwipedRight = true
                            hasSwipedLeft = false
                            
                            // TODO: In the future, send signal to recommendation algorithm
                            // For now, just visual feedback
                            
                            // Animate the post sliding further right before snapping back
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                swipeOffset = maxSwipeDistance * 1.2
                            }
                            
                            // Then snap back to center
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    swipeOffset = 0
                                }
                            }
                        } else if swipeOffset < -swipeThreshold {
                            // Left swipe - negative algorithm feedback
                            hasSwipedLeft = true
                            hasSwipedRight = false
                            
                            // TODO: In the future, send signal to recommendation algorithm
                            // For now, just visual feedback
                            
                            // Animate the post sliding further left before snapping back
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                swipeOffset = -maxSwipeDistance * 1.2
                            }
                            
                            // Then snap back to center
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    swipeOffset = 0
                                }
                            }
                        } else {
                            // Snap back to center if not past threshold
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                swipeOffset = 0
                            }
                        }
                        
                        // Reset triggers
                        hasTriggeredLike = false
                        hasTriggeredDislike = false
                    } else {
                        // Always spring back if not dragging
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            swipeOffset = 0
                        }
                    }
                }
        )
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: backgroundColor)
        .sheet(isPresented: $showReplies) {
            RepliesView(post: post, feedService: feedService)
                .presentationDetents([.fraction(0.9)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
    }
}

// Preference key to track content height
struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview
#Preview("Simple Test") {
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri",
            cid: "sample-cid",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Test post to check if ActionBar appears",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 5,
            repostCount: 10,
            likeCount: 15,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: BSViewer(like: nil, repost: nil, threadMuted: false, embeddingDisabled: false),
            labels: nil,
            embed: nil
        ),
        reply: nil,
        reason: nil,
        embed: nil,
        viewer: nil,
        labels: nil
    )
    
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400, height: 200)
        .padding()
}

#Preview("Text Only", traits: .sizeThatFitsLayout) {
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri",
            cid: "sample-cid",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Just finished reading 'The Midnight Library' by Matt Haig. What an incredible journey through infinite possibilities! The way it explores regret, choice, and the beauty of ordinary life really resonated with me. Highly recommend this thought-provoking read. #BookReview #TheMidnightLibrary",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 5,
            repostCount: 10,
            likeCount: 15,
            quoteCount: 0,
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
    )
    
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400)
        .padding()
}

#Preview("Single Image", traits: .sizeThatFitsLayout) {
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri",
            cid: "sample-cid",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Check out this beautiful sunset! 🌅",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 5,
            repostCount: 10,
            likeCount: 15,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: nil
        ),
        reply: nil,
        reason: nil,
        embed: BSEmbed(
            type: "app.bsky.embed.images",
            record: nil,
            media: BSEmbedMedia(
                type: "app.bsky.embed.images",
                images: [
                    BSEmbedImage(
                        thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                        fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                        alt: "Beautiful sunset over the ocean",
                        aspectRatio: AspectRatio(height: 1023, width: 633),
                        image: nil
                    )
                ]
            ),
            images: [
                BSEmbedImage(
                    thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                    fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                    alt: "Beautiful sunset over the ocean",
                    aspectRatio: AspectRatio(height: 1023, width: 633),
                    image: nil
                )
            ],
            external: nil
        ),
        viewer: nil,
        labels: nil
    )
    
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400)
        .padding()
}

#Preview("Two Images", traits: .sizeThatFitsLayout) {
    let images = [
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:abc/image1@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:abc/image1@jpeg",
            alt: "First image",
            aspectRatio: AspectRatio(height: 800, width: 1200),
            image: nil
        ),
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:def/image2@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:def/image2@jpeg",
            alt: "Second image",
            aspectRatio: AspectRatio(height: 900, width: 900),
            image: nil
        )
    ]
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri-2",
            cid: "sample-cid-2",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Here's a post with two images!",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 2,
            repostCount: 3,
            likeCount: 5,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: nil
        ),
        reply: nil,
        reason: nil,
        embed: BSEmbed(
            type: "app.bsky.embed.images",
            record: nil,
            media: BSEmbedMedia(type: "app.bsky.embed.images", images: images),
            images: images,
            external: nil
        ),
        viewer: nil,
        labels: nil
    )
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400)
        .padding()
}

#Preview("Three Images", traits: .sizeThatFitsLayout) {
    let images = [
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:ghi/image3@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:ghi/image3@jpeg",
            alt: "Third image",
            aspectRatio: AspectRatio(height: 900, width: 700),
            image: nil
        ),
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:jkl/image4@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:jkl/image4@jpeg",
            alt: "Fourth image",
            aspectRatio: AspectRatio(height: 800, width: 1200),
            image: nil
        ),
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:mno/image5@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:mno/image5@jpeg",
            alt: "Fifth image",
            aspectRatio: AspectRatio(height: 1000, width: 1000),
            image: nil
        )
    ]
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri-3",
            cid: "sample-cid-3",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Here's a post with three images!",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 3,
            repostCount: 4,
            likeCount: 6,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: nil
        ),
        reply: nil,
        reason: nil,
        embed: BSEmbed(
            type: "app.bsky.embed.images",
            record: nil,
            media: BSEmbedMedia(type: "app.bsky.embed.images", images: images),
            images: images,
            external: nil
        ),
        viewer: nil,
        labels: nil
    )
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400)
        .padding()
}

#Preview("Four Images", traits: .sizeThatFitsLayout) {
    let images = [
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:pqr/image6@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:pqr/image6@jpeg",
            alt: "Sixth image",
            aspectRatio: AspectRatio(height: 900, width: 900),
            image: nil
        ),
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:stu/image7@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:stu/image7@jpeg",
            alt: "Seventh image",
            aspectRatio: AspectRatio(height: 800, width: 1200),
            image: nil
        ),
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:vwx/image8@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:vwx/image8@jpeg",
            alt: "Eighth image",
            aspectRatio: AspectRatio(height: 1000, width: 1000),
            image: nil
        ),
        BSEmbedImage(
            thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:yz/image9@jpeg",
            fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:yz/image9@jpeg",
            alt: "Ninth image",
            aspectRatio: AspectRatio(height: 1200, width: 800),
            image: nil
        )
    ]
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri-4",
            cid: "sample-cid-4",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Here's a post with four images!",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 4,
            repostCount: 5,
            likeCount: 7,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: nil
        ),
        reply: nil,
        reason: nil,
        embed: BSEmbed(
            type: "app.bsky.embed.images",
            record: nil,
            media: BSEmbedMedia(type: "app.bsky.embed.images", images: images),
            images: images,
            external: nil
        ),
        viewer: nil,
        labels: nil
    )
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400)
        .padding()
}

#Preview("Embedded Post (Quote)", traits: .sizeThatFitsLayout) {
    let quotedAuthor = BSAuthor(
        did: "quoted-did",
        handle: "quoted.handle",
        displayName: "Quoted User",
        avatar: nil,
        associated: nil,
        viewer: nil,
        labels: nil,
        createdAt: "2024-03-19T10:00:00Z"
    )
    let quotedRecord = BSPostRecord(
        type: "app.bsky.feed.post",
        text: "This is the quoted post's text!",
        createdAt: "2024-03-19T10:00:00Z",
        embed: nil,
        reply: nil,
        langs: nil,
        facets: nil
    )
    let quotedPost = BSPost(
        uri: "quoted-uri",
        cid: "quoted-cid",
        author: quotedAuthor,
        record: quotedRecord,
        replyCount: 1,
        repostCount: 2,
        likeCount: 3,
        quoteCount: 0,
        indexedAt: "2024-03-19T10:00:00Z",
        viewer: nil,
        labels: nil,
        embed: nil
    )
    let quotedEmbedView = BSEmbedRecordView(
        type: "app.bsky.embed.record",
        uri: "quoted-uri",
        cid: "quoted-cid",
        post: quotedPost,
        value: quotedRecord,
        labels: nil,
        likeCount: 3,
        replyCount: 1,
        repostCount: 2,
        quoteCount: 0,
        indexedAt: "2024-03-19T10:00:00Z",
        embeds: nil,
        viewer: nil
    )
    let embed = BSEmbed(
        type: "app.bsky.embed.record",
        record: BSEmbedRecord(
            type: "app.bsky.embed.record",
            record: quotedEmbedView,
            media: nil
        ),
        media: nil,
        images: nil,
        external: nil
    )
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri-quote",
            cid: "sample-cid-quote",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Here's a post quoting another post!",
                createdAt: "2024-03-20T12:00:00Z",
                embed: embed,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 1,
            repostCount: 1,
            likeCount: 1,
            quoteCount: 1,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: embed
        ),
        reply: nil,
        reason: nil,
        embed: embed,
        viewer: nil,
        labels: nil
    )
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400)
        .padding()
}

#Preview("External Link", traits: .sizeThatFitsLayout) {
    let externalData = """
    {
        "uri": "https://example.com/article",
        "title": "Amazing Article About SwiftUI",
        "description": "Learn about the latest SwiftUI features and best practices for building modern iOS apps.",
        "thumb": "https://picsum.photos/600/400"
    }
    """
    
    let external = try! JSONDecoder().decode(BSEmbedExternal.self, from: externalData.data(using: .utf8)!)
    
    let embed = BSEmbed(
        type: "app.bsky.embed.external",
        record: nil,
        media: nil,
        images: nil,
        external: external
    )
    
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri-external",
            cid: "sample-cid-external",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Check out this great article about SwiftUI!",
                createdAt: "2024-03-20T12:00:00Z",
                embed: embed,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 2,
            repostCount: 5,
            likeCount: 12,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: embed
        ),
        reply: nil,
        reason: nil,
        embed: embed,
        viewer: nil,
        labels: nil
    )
    
    PostView(post: samplePost, feedService: MockBlueSkyFeedService())
        .frame(width: 400)
        .padding()
} 
