import Foundation

struct BSAuthor: Codable {
    let did: String
    let handle: String
    let displayName: String?
    let avatar: String?
    let associated: Associated?
    let viewer: AuthorViewer?
    let labels: [FeedLabel]?
    let createdAt: String
    
    /// Returns the handle without the .bsky.social suffix if present
    var formattedHandle: String {
        handle.formatBlueskyHandle()
    }
    
    init(
        did: String,
        handle: String,
        displayName: String? = nil,
        avatar: String? = nil,
        associated: Associated? = nil,
        viewer: AuthorViewer? = nil,
        labels: [FeedLabel]? = nil,
        createdAt: String
    ) {
        self.did = did
        self.handle = handle
        self.displayName = displayName
        self.avatar = avatar
        self.associated = associated
        self.viewer = viewer
        self.labels = labels
        self.createdAt = createdAt
    }
}

struct Associated: Codable {
    let chat: Chat?
}

struct Chat: Codable {
    let allowIncoming: String?
}

struct AuthorViewer: Codable {
    let muted: Bool?
    let blockedBy: Bool?
    let following: String?
}
