import Foundation
import SwiftData

@Model
final class Draft {
    var id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isPublished: Bool
    var publishedAt: Date?
    
    // Optional metadata
    var tags: [String]?
    var isLoopThread: Bool
    var isDailyPrompt: Bool
    
    // Relationships
    @Relationship(inverse: \Profile.drafts) var author: Profile?
    
    init(
        content: String,
        tags: [String]? = nil,
        isLoopThread: Bool = false,
        isDailyPrompt: Bool = false
    ) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isPublished = false
        self.tags = tags
        self.isLoopThread = isLoopThread
        self.isDailyPrompt = isDailyPrompt
    }
    
    func publish() {
        isPublished = true
        publishedAt = Date()
    }
}

// MARK: - Codable
extension Draft: Codable {
    enum CodingKeys: String, CodingKey {
        case id, content, createdAt, updatedAt, isPublished, publishedAt
        case tags, isLoopThread, isDailyPrompt, author
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let content = try container.decode(String.self, forKey: .content)
        let tags = try container.decodeIfPresent([String].self, forKey: .tags)
        let isLoopThread = try container.decode(Bool.self, forKey: .isLoopThread)
        let isDailyPrompt = try container.decode(Bool.self, forKey: .isDailyPrompt)
        
        self.init(
            content: content,
            tags: tags,
            isLoopThread: isLoopThread,
            isDailyPrompt: isDailyPrompt
        )
        
        // Decode additional properties
        self.id = try container.decode(UUID.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.isPublished = try container.decode(Bool.self, forKey: .isPublished)
        self.publishedAt = try container.decodeIfPresent(Date.self, forKey: .publishedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(isPublished, forKey: .isPublished)
        try container.encodeIfPresent(publishedAt, forKey: .publishedAt)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encode(isLoopThread, forKey: .isLoopThread)
        try container.encode(isDailyPrompt, forKey: .isDailyPrompt)
        try container.encodeIfPresent(author, forKey: .author)
    }
} 