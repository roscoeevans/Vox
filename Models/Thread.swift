import Foundation
import SwiftData

@Model
final class Thread {
    var id: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var likes: Int
    var reposts: Int
    var replies: Int
    
    // Relationships
    @Relationship(inverse: \Profile.threads) var author: Profile?
    
    init(
        id: String = UUID().uuidString,
        content: String,
        author: Profile? = nil
    ) {
        self.id = id
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.likes = 0
        self.reposts = 0
        self.replies = 0
        self.author = author
    }
}

// MARK: - Codable
extension Thread: Codable {
    enum CodingKeys: String, CodingKey {
        case id, content, createdAt, updatedAt, likes, reposts, replies, author
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let content = try container.decode(String.self, forKey: .content)
        let author = try container.decodeIfPresent(Profile.self, forKey: .author)
        
        self.init(id: id, content: content, author: author)
        
        // Decode additional properties
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.likes = try container.decode(Int.self, forKey: .likes)
        self.reposts = try container.decode(Int.self, forKey: .reposts)
        self.replies = try container.decode(Int.self, forKey: .replies)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(likes, forKey: .likes)
        try container.encode(reposts, forKey: .reposts)
        try container.encode(replies, forKey: .replies)
        try container.encodeIfPresent(author, forKey: .author)
    }
} 