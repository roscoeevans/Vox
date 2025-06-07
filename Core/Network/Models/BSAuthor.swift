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
    
    /// Returns the handle formatted for display using the default configuration
    var formattedHandle: String {
        HandleFormatter.shared.formatForFeed(handle, isVerified: isVerified)
    }
    
    /// Returns the handle formatted for compact display
    var compactHandle: String {
        HandleFormatter.shared.formatCompact(handle)
    }
    
    /// Returns the handle formatted for profile display
    var profileHandle: String {
        HandleFormatter.shared.formatForProfile(handle)
    }
    
    /// Checks if the author might be verified based on their handle domain
    var isVerified: Bool {
        // Check if the handle has a custom domain
        guard let domain = handle.handleDomain else { return false }
        
        // Get the formatted handle - if it's different from the original,
        // then a common suffix was removed, so it's not a verified domain
        let formatted = HandleFormatter.shared.format(handle, mode: .smart)
        
        // If the formatted version is the same as the original handle,
        // it means no common suffix was removed, indicating a custom domain
        return formatted == handle && !domain.isEmpty
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
