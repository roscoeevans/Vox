import Foundation

class BSEmbed: Codable {
    let type: String?
    let record: BSEmbedRecord?
    let media: BSEmbedMedia?
    let images: [BSEmbedImage]?
    let external: BSEmbedExternal?
    
    init(
        type: String?,
        record: BSEmbedRecord?,
        media: BSEmbedMedia?,
        images: [BSEmbedImage]?,
        external: BSEmbedExternal?
    ) {
        self.type = type
        self.record = record
        self.media = media
        self.images = images
        self.external = external
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case record
        case media
        case images
        case external
    }
}

class BSEmbedRecord: Codable {
    let type: String?
    let record: BSEmbedRecordView?
    let media: BSEmbedMedia?
    
    init(
        type: String?,
        record: BSEmbedRecordView?,
        media: BSEmbedMedia?
    ) {
        self.type = type
        self.record = record
        self.media = media
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case record
        case media
    }
}

class BSEmbedRecordView: Codable {
    let type: String?
    let uri: String?
    let cid: String?
    let post: BSPost?
    let value: BSPostRecord?
    let labels: [FeedLabel]?
    let likeCount: Int?
    let replyCount: Int?
    let repostCount: Int?
    let quoteCount: Int?
    let indexedAt: String?
    let embeds: [BSEmbed]?
    let viewer: BSViewer?
    
    init(
        type: String?,
        uri: String?,
        cid: String?,
        post: BSPost?,
        value: BSPostRecord?,
        labels: [FeedLabel]?,
        likeCount: Int?,
        replyCount: Int?,
        repostCount: Int?,
        quoteCount: Int?,
        indexedAt: String?,
        embeds: [BSEmbed]?,
        viewer: BSViewer?
    ) {
        self.type = type
        self.uri = uri
        self.cid = cid
        self.post = post
        self.value = value
        self.labels = labels
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.repostCount = repostCount
        self.quoteCount = quoteCount
        self.indexedAt = indexedAt
        self.embeds = embeds
        self.viewer = viewer
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case uri
        case cid
        case post
        case value
        case labels
        case likeCount
        case replyCount
        case repostCount
        case quoteCount
        case indexedAt
        case embeds
        case viewer
    }
}

class BSEmbedMedia: Codable {
    let type: String?
    let images: [BSEmbedImage]?
    
    init(
        type: String?,
        images: [BSEmbedImage]?
    ) {
        self.type = type
        self.images = images
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case images
    }
}

class BSEmbedImage: Codable {
    let thumb: String?
    let fullsize: String?
    let alt: String?
    let aspectRatio: AspectRatio
    let image: BSImage?
    
    init(
        thumb: String?,
        fullsize: String?,
        alt: String?,
        aspectRatio: AspectRatio,
        image: BSImage?
    ) {
        self.thumb = thumb
        self.fullsize = fullsize
        self.alt = alt
        self.aspectRatio = aspectRatio
        self.image = image
    }
}

class BSImage: Codable {
    let type: String?
    let ref: BSRef?
    let mimeType: String?
    let size: Int?
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case ref
        case mimeType
        case size
    }
}

class BSRef: Codable {
    let link: String?
    
    enum CodingKeys: String, CodingKey {
        case link = "$link"
    }
}

class BSEmbedExternal: Codable {
    let uri: String
    let title: String
    let description: String
    let thumb: String?
    let thumbBlob: BSImage?
    
    enum CodingKeys: String, CodingKey {
        case uri
        case title
        case description
        case thumb
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uri = try container.decode(String.self, forKey: .uri)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        
        // Try to decode thumb as string first
        if let thumbString = try? container.decode(String.self, forKey: .thumb) {
            thumb = thumbString
            thumbBlob = nil
        } else {
            // If not a string, try to decode as BSImage
            thumb = nil
            thumbBlob = try? container.decode(BSImage.self, forKey: .thumb)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uri, forKey: .uri)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        if let thumbString = thumb {
            try container.encode(thumbString, forKey: .thumb)
        } else if let thumbBlob = thumbBlob {
            try container.encode(thumbBlob, forKey: .thumb)
        }
    }
}

struct AspectRatio: Codable {
    let height: Int
    let width: Int
}

class BSViewer: Codable {
    let like: String?
    let threadMuted: Bool?
    let embeddingDisabled: Bool?
} 