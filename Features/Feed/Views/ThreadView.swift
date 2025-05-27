import SwiftUI
import ATProtoKit

// Import subcomponents
// (Assume module or file imports as needed for Swift)

// Helper for per-corner rounding
struct RoundedCorner: Shape {
    var radius: CGFloat = 12.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Main Component
struct ThreadView: View {
    let post: FeedViewPost
    
    // MARK: - Button States
    @State private var isLiked = false
    @State private var isReplied = false
    @State private var isReposted = false
    
    var body: some View {
        let minActionsHeight: CGFloat = 80 // Adjust as needed for your design
        VStack(alignment: .leading) {
            // Post Header
            HStack {
                ProfileImage(avatarURLString: post.author.avatar)
                Text("@\(post.author.formattedHandle)")
                    .font(.headline)
            }
            HStack(alignment: .bottom, spacing: 16) {
                PostContent(post: post)
                PostActions(
                    post: post,
                    isLiked: $isLiked,
                    isReplied: $isReplied,
                    isReposted: $isReposted
                )
            }
            .frame(minHeight: minActionsHeight)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

// MARK: - Preview
#Preview("Text Only") {
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
    
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Single Image") {
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
    
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Two Images") {
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
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Three Images") {
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
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Four Images") {
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
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Embedded Post (Quote)") {
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
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
} 
