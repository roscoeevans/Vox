import Foundation

class BSEmbed: Codable {
    let type: String?
    let record: BSEmbedRecord?
    let media: BSEmbedMedia?
    let images: [BSEmbedImage]?
    let external: BSEmbedExternal?
    let video: BSEmbedVideo?
    
    // Properties for record#view types
    let uri: String?
    let cid: String?
    let author: BSAuthor?
    let value: BSPostRecord?
    let likeCount: Int?
    let replyCount: Int?
    let repostCount: Int?
    let quoteCount: Int?
    let indexedAt: String?
    let embeds: [BSEmbed]?
    
    // Properties for video#view types
    let playlist: String?
    let thumbnail: String?
    let alt: String?
    let aspectRatio: AspectRatio?
    
    init(
        type: String?,
        record: BSEmbedRecord?,
        media: BSEmbedMedia?,
        images: [BSEmbedImage]?,
        external: BSEmbedExternal?,
        video: BSEmbedVideo? = nil,
        uri: String? = nil,
        cid: String? = nil,
        author: BSAuthor? = nil,
        value: BSPostRecord? = nil,
        likeCount: Int? = nil,
        replyCount: Int? = nil,
        repostCount: Int? = nil,
        quoteCount: Int? = nil,
        indexedAt: String? = nil,
        embeds: [BSEmbed]? = nil,
        playlist: String? = nil,
        thumbnail: String? = nil,
        alt: String? = nil,
        aspectRatio: AspectRatio? = nil
    ) {
        self.type = type
        self.record = record
        self.media = media
        self.images = images
        self.external = external
        self.video = video
        self.uri = uri
        self.cid = cid
        self.author = author
        self.value = value
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.repostCount = repostCount
        self.quoteCount = quoteCount
        self.indexedAt = indexedAt
        self.embeds = embeds
        self.playlist = playlist
        self.thumbnail = thumbnail
        self.alt = alt
        self.aspectRatio = aspectRatio
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case record
        case media
        case images
        case external
        case video
        case uri
        case cid
        case author
        case value
        case likeCount
        case replyCount
        case repostCount
        case quoteCount
        case indexedAt
        case embeds
        case playlist
        case thumbnail
        case alt
        case aspectRatio
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decodeIfPresent(String.self, forKey: .type)
        
        // Handle video embed type specially
        if type == "app.bsky.embed.video" {
            // For video embeds in record.embed, the video data is directly in the embed
            if let videoData = try? container.decode(BSImage.self, forKey: .video) {
                let altText = try container.decodeIfPresent(String.self, forKey: .alt)
                let ratio = try container.decodeIfPresent(AspectRatio.self, forKey: .aspectRatio)
                video = BSEmbedVideo(
                    video: videoData,
                    captions: nil,
                    alt: altText,
                    aspectRatio: ratio,
                    thumb: nil
                )
            } else {
                video = nil
            }
            
            // Set other properties to nil
            record = nil
            media = nil
            images = nil
            external = nil
            uri = nil
            cid = nil
            author = nil
            value = nil
            likeCount = nil
            replyCount = nil
            repostCount = nil
            quoteCount = nil
            indexedAt = nil
            embeds = nil
            playlist = nil
            thumbnail = nil
            alt = try container.decodeIfPresent(String.self, forKey: .alt)
            aspectRatio = try container.decodeIfPresent(AspectRatio.self, forKey: .aspectRatio)
        } else if type == "app.bsky.embed.video#view" {
            // For video view embeds at the top level, we have playlist and thumbnail
            video = nil
            record = nil
            media = nil
            images = nil
            external = nil
            uri = nil
            cid = try container.decodeIfPresent(String.self, forKey: .cid)
            author = nil
            value = nil
            likeCount = nil
            replyCount = nil
            repostCount = nil
            quoteCount = nil
            indexedAt = nil
            embeds = nil
            playlist = try container.decodeIfPresent(String.self, forKey: .playlist)
            thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
            alt = try container.decodeIfPresent(String.self, forKey: .alt)
            aspectRatio = try container.decodeIfPresent(AspectRatio.self, forKey: .aspectRatio)
        } else {
            // Normal decoding for other types
            record = try container.decodeIfPresent(BSEmbedRecord.self, forKey: .record)
            media = try container.decodeIfPresent(BSEmbedMedia.self, forKey: .media)
            images = try container.decodeIfPresent([BSEmbedImage].self, forKey: .images)
            external = try container.decodeIfPresent(BSEmbedExternal.self, forKey: .external)
            video = try container.decodeIfPresent(BSEmbedVideo.self, forKey: .video)
            uri = try container.decodeIfPresent(String.self, forKey: .uri)
            cid = try container.decodeIfPresent(String.self, forKey: .cid)
            author = try container.decodeIfPresent(BSAuthor.self, forKey: .author)
            value = try container.decodeIfPresent(BSPostRecord.self, forKey: .value)
            likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount)
            replyCount = try container.decodeIfPresent(Int.self, forKey: .replyCount)
            repostCount = try container.decodeIfPresent(Int.self, forKey: .repostCount)
            quoteCount = try container.decodeIfPresent(Int.self, forKey: .quoteCount)
            indexedAt = try container.decodeIfPresent(String.self, forKey: .indexedAt)
            embeds = try container.decodeIfPresent([BSEmbed].self, forKey: .embeds)
            playlist = nil
            thumbnail = nil
            alt = nil
            aspectRatio = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(record, forKey: .record)
        try container.encodeIfPresent(media, forKey: .media)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(external, forKey: .external)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(uri, forKey: .uri)
        try container.encodeIfPresent(cid, forKey: .cid)
        try container.encodeIfPresent(author, forKey: .author)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(likeCount, forKey: .likeCount)
        try container.encodeIfPresent(replyCount, forKey: .replyCount)
        try container.encodeIfPresent(repostCount, forKey: .repostCount)
        try container.encodeIfPresent(quoteCount, forKey: .quoteCount)
        try container.encodeIfPresent(indexedAt, forKey: .indexedAt)
        try container.encodeIfPresent(embeds, forKey: .embeds)
        try container.encodeIfPresent(playlist, forKey: .playlist)
        try container.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(alt, forKey: .alt)
        try container.encodeIfPresent(aspectRatio, forKey: .aspectRatio)
    }
}

class BSEmbedRecord: Codable {
    let type: String?
    let record: BSEmbedRecordView?
    let media: BSEmbedMedia?
    
    // Properties that come directly in record for view types
    let uri: String?
    let cid: String?
    let author: BSAuthor?
    let value: BSPostRecord?
    let likeCount: Int?
    let replyCount: Int?
    let repostCount: Int?
    let quoteCount: Int?
    let indexedAt: String?
    let embeds: [BSEmbed]?
    
    init(
        type: String?,
        record: BSEmbedRecordView?,
        media: BSEmbedMedia?,
        uri: String? = nil,
        cid: String? = nil,
        author: BSAuthor? = nil,
        value: BSPostRecord? = nil,
        likeCount: Int? = nil,
        replyCount: Int? = nil,
        repostCount: Int? = nil,
        quoteCount: Int? = nil,
        indexedAt: String? = nil,
        embeds: [BSEmbed]? = nil
    ) {
        self.type = type
        self.record = record
        self.media = media
        self.uri = uri
        self.cid = cid
        self.author = author
        self.value = value
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.repostCount = repostCount
        self.quoteCount = quoteCount
        self.indexedAt = indexedAt
        self.embeds = embeds
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case record
        case media
        case uri
        case cid
        case author
        case value
        case likeCount
        case replyCount
        case repostCount
        case quoteCount
        case indexedAt
        case embeds
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
    let repost: String?
    let threadMuted: Bool?
    let embeddingDisabled: Bool?
    
    init(
        like: String? = nil,
        repost: String? = nil,
        threadMuted: Bool? = nil,
        embeddingDisabled: Bool? = nil
    ) {
        self.like = like
        self.repost = repost
        self.threadMuted = threadMuted
        self.embeddingDisabled = embeddingDisabled
    }
}

class BSEmbedVideo: Codable {
    let video: BSImage  // BlobRef for the video
    let captions: [BSVideoCaption]?
    let alt: String?
    let aspectRatio: AspectRatio?
    let thumb: String?  // Thumbnail URL
    
    init(
        video: BSImage,
        captions: [BSVideoCaption]? = nil,
        alt: String? = nil,
        aspectRatio: AspectRatio? = nil,
        thumb: String? = nil
    ) {
        self.video = video
        self.captions = captions
        self.alt = alt
        self.aspectRatio = aspectRatio
        self.thumb = thumb
    }
}

class BSVideoCaption: Codable {
    let lang: String
    let file: BSImage  // BlobRef for caption file
    
    init(lang: String, file: BSImage) {
        self.lang = lang
        self.file = file
    }
} 