import Foundation

struct FeedViewPost: Codable {
    let post: BSPost
    let reply: BSReply?
    let reason: BSReason?
    let embed: BSEmbed?
    let viewer: BSViewer?
    let labels: [FeedLabel]?
    
    enum CodingKeys: String, CodingKey {
        case post
        case reply
        case reason
        case embed
        case viewer
        case labels
    }
    
    var author: BSAuthor {
        post.author
    }
}

struct FeedLabel: Codable {
    let src: String?
    let uri: String?
    let cid: String?
    let val: String?
    let cts: String?
}

// MARK: - Mock Data
extension FeedViewPost {
    static let mockPost = FeedViewPost(
        post: BSPost(
            uri: "at://did:plc:mock/app.bsky.feed.post/123",
            cid: "bafyreimock123",
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
                text: "This post could not be loaded",
                createdAt: "2024-01-01T00:00:00Z",
                embed: nil,
                reply: nil,
                langs: ["en"],
                facets: nil
            ),
            replyCount: 0,
            repostCount: 0,
            likeCount: 0,
            quoteCount: 0,
            indexedAt: "2024-01-01T00:00:00Z",
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
} 