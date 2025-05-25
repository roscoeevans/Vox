import Foundation

struct BSReason: Codable {
    let type: String?
    let by: BSAuthor?
    let indexedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case by
        case indexedAt
    }
} 