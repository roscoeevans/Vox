import Foundation

class BSPost: Codable {
    let uri: String
    let cid: String
    let author: BSAuthor
    let record: BSPostRecord
    let replyCount: Int
    let repostCount: Int
    let likeCount: Int
    let quoteCount: Int
    let indexedAt: String
    let viewer: BSViewer?
    let labels: [FeedLabel]?
    let embed: BSEmbed?
    
    init(
        uri: String,
        cid: String,
        author: BSAuthor,
        record: BSPostRecord,
        replyCount: Int,
        repostCount: Int,
        likeCount: Int,
        quoteCount: Int,
        indexedAt: String,
        viewer: BSViewer? = nil,
        labels: [FeedLabel]? = nil,
        embed: BSEmbed? = nil
    ) {
        self.uri = uri
        self.cid = cid
        self.author = author
        self.record = record
        self.replyCount = replyCount
        self.repostCount = repostCount
        self.likeCount = likeCount
        self.quoteCount = quoteCount
        self.indexedAt = indexedAt
        self.viewer = viewer
        self.labels = labels
        self.embed = embed
    }
    
    enum CodingKeys: String, CodingKey {
        case uri
        case cid
        case author
        case record
        case replyCount
        case repostCount
        case likeCount
        case quoteCount
        case indexedAt
        case viewer
        case labels
        case embed
    }
}

struct BSPostRecord: Codable {
    let type: String?
    let text: String
    let createdAt: String
    let embed: BSEmbed?
    let reply: Reply?
    let langs: [String]?
    let facets: [Facet]?
    
    init(
        type: String? = nil,
        text: String,
        createdAt: String,
        embed: BSEmbed? = nil,
        reply: Reply? = nil,
        langs: [String]? = nil,
        facets: [Facet]? = nil
    ) {
        self.type = type
        self.text = text
        self.createdAt = createdAt
        self.embed = embed
        self.reply = reply
        self.langs = langs
        self.facets = facets
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case text
        case createdAt
        case embed
        case reply
        case langs
        case facets
    }
}

struct Reply: Codable {
    let root: ReplyReference
    let parent: ReplyReference
}

struct ReplyReference: Codable {
    let cid: String
    let uri: String
}

struct Facet: Codable {
    let features: [FacetFeature]
    let index: FacetIndex
}

struct FacetFeature: Codable {
    let type: String
    let uri: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case uri
    }
}

struct FacetIndex: Codable {
    let byteStart: Int
    let byteEnd: Int
}

struct PostViewer: Codable {
    let threadMuted: Bool?
    let embeddingDisabled: Bool?
}

// Helper for type-erased decoding
struct AnyCodable: Codable {
    let value: Any
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else if let arrVal = try? container.decode([AnyCodable].self) {
            value = arrVal
        } else {
            value = ()
        }
    }
    func encode(to encoder: Encoder) throws {
        // Not needed for decoding timeline
    }
} 