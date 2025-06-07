import Foundation

struct BSReply: Codable {
    let root: BSReplyRef?
    let parent: BSReplyRef?
}

struct BSReplyRef: Codable {
    let uri: String
    let cid: String
}
 
