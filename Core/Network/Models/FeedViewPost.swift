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