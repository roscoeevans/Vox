import Foundation
import SwiftData

@Model
final class Profile {
    var id: String
    var handle: String
    var displayName: String
    var bio: String?
    var avatarURL: URL?
    var bannerURL: URL?
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var drafts: [Draft]?
    @Relationship(deleteRule: .cascade) var threads: [Thread]?
    
    init(
        id: String,
        handle: String,
        displayName: String,
        bio: String? = nil,
        avatarURL: URL? = nil,
        bannerURL: URL? = nil
    ) {
        self.id = id
        self.handle = handle
        self.displayName = displayName
        self.bio = bio
        self.avatarURL = avatarURL
        self.bannerURL = bannerURL
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Codable
extension Profile: Codable {
    enum CodingKeys: String, CodingKey {
        case id, handle, displayName, bio, avatarURL, bannerURL, createdAt, updatedAt
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let handle = try container.decode(String.self, forKey: .handle)
        let displayName = try container.decode(String.self, forKey: .displayName)
        let bio = try container.decodeIfPresent(String.self, forKey: .bio)
        let avatarURL = try container.decodeIfPresent(URL.self, forKey: .avatarURL)
        let bannerURL = try container.decodeIfPresent(URL.self, forKey: .bannerURL)
        
        self.init(
            id: id,
            handle: handle,
            displayName: displayName,
            bio: bio,
            avatarURL: avatarURL,
            bannerURL: bannerURL
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(handle, forKey: .handle)
        try container.encode(displayName, forKey: .displayName)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(avatarURL, forKey: .avatarURL)
        try container.encodeIfPresent(bannerURL, forKey: .bannerURL)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
} 