import Foundation

protocol FeedServiceProtocol {
    func getTimeline(cursor: String?) async throws -> TimelineResponse
    func likePost(uri: String, cid: String) async throws -> LikeResponse
    func unlikePost(uri: String) async throws
    func repostPost(uri: String, cid: String) async throws -> RepostResponse
    func unrepostPost(uri: String) async throws
    func getPostThread(uri: String, depth: Int?, parentHeight: Int?) async throws -> PostThreadResponse
    func createReply(text: String, parentUri: String, parentCid: String, rootUri: String, rootCid: String) async throws -> CreatePostResponse
}

actor BlueSkyFeedService: FeedServiceProtocol {
    // MARK: - Properties
    private let baseURL = "https://bsky.social/xrpc/"
    private let authService: BlueSkyAuthService
    
    // MARK: - Initialization
    init(authService: BlueSkyAuthService) {
        self.authService = authService
    }
    
    // MARK: - Feed Methods
    func getTimeline(cursor: String? = nil) async throws -> TimelineResponse {
        guard let session = await authService.currentSession else {
            throw BlueSkyError.noActiveSession
        }
        
        let endpoint = "app.bsky.feed.getTimeline"
        let url = URL(string: baseURL + endpoint)!
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "50")
        ]
        if let cursor = cursor {
            components.queryItems?.append(URLQueryItem(name: "cursor", value: cursor))
        }
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(session.accessJwt)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print("[FeedService] Raw response: \(String(data: data, encoding: .utf8) ?? "<non-utf8 data>")")
        print("[FeedService] HTTP response: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BlueSkyError.networkError
        }
        
        do {
            return try JSONDecoder().decode(TimelineResponse.self, from: data)
        } catch {
            print("[FeedService] Decoding error: \(error)")
            throw error
        }
    }
    
    // MARK: - Like Methods
    func likePost(uri: String, cid: String) async throws -> LikeResponse {
        guard let session = await authService.currentSession else {
            throw BlueSkyError.noActiveSession
        }
        
        let endpoint = "com.atproto.repo.createRecord"
        let url = URL(string: baseURL + endpoint)!
        
        let body: [String: Any] = [
            "repo": session.did,
            "collection": "app.bsky.feed.like",
            "record": [
                "$type": "app.bsky.feed.like",
                "subject": [
                    "uri": uri,
                    "cid": cid
                ],
                "createdAt": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessJwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BlueSkyError.networkError
        }
        
        return try JSONDecoder().decode(LikeResponse.self, from: data)
    }
    
    func unlikePost(uri: String) async throws {
        guard let session = await authService.currentSession else {
            throw BlueSkyError.noActiveSession
        }
        
        // Parse the URI to get the record key
        let components = uri.split(separator: "/")
        guard components.count >= 2,
              let recordKey = components.last else {
            throw BlueSkyError.invalidURI
        }
        
        let endpoint = "com.atproto.repo.deleteRecord"
        let url = URL(string: baseURL + endpoint)!
        
        let body: [String: Any] = [
            "repo": session.did,
            "collection": "app.bsky.feed.like",
            "rkey": String(recordKey)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessJwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BlueSkyError.networkError
        }
    }
    
    // MARK: - Repost Methods
    func repostPost(uri: String, cid: String) async throws -> RepostResponse {
        guard let session = await authService.currentSession else {
            throw BlueSkyError.noActiveSession
        }
        
        let endpoint = "com.atproto.repo.createRecord"
        let url = URL(string: baseURL + endpoint)!
        
        let body: [String: Any] = [
            "repo": session.did,
            "collection": "app.bsky.feed.repost",
            "record": [
                "$type": "app.bsky.feed.repost",
                "subject": [
                    "uri": uri,
                    "cid": cid
                ],
                "createdAt": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessJwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BlueSkyError.networkError
        }
        
        return try JSONDecoder().decode(RepostResponse.self, from: data)
    }
    
    func unrepostPost(uri: String) async throws {
        guard let session = await authService.currentSession else {
            throw BlueSkyError.noActiveSession
        }
        
        // Parse the URI to get the record key
        let components = uri.split(separator: "/")
        guard components.count >= 2,
              let recordKey = components.last else {
            throw BlueSkyError.invalidURI
        }
        
        let endpoint = "com.atproto.repo.deleteRecord"
        let url = URL(string: baseURL + endpoint)!
        
        let body: [String: Any] = [
            "repo": session.did,
            "collection": "app.bsky.feed.repost",
            "rkey": String(recordKey)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessJwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BlueSkyError.networkError
        }
    }
    
    // MARK: - Thread Methods
    func getPostThread(uri: String, depth: Int? = nil, parentHeight: Int? = nil) async throws -> PostThreadResponse {
        guard let session = await authService.currentSession else {
            throw BlueSkyError.noActiveSession
        }
        
        let endpoint = "app.bsky.feed.getPostThread"
        let url = URL(string: baseURL + endpoint)!
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "uri", value: uri)
        ]
        if let depth = depth {
            components.queryItems?.append(URLQueryItem(name: "depth", value: String(depth)))
        }
        if let parentHeight = parentHeight {
            components.queryItems?.append(URLQueryItem(name: "parentHeight", value: String(parentHeight)))
        }
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(session.accessJwt)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug logging
        print("[getPostThread] Request URL: \(components.url!)")
        print("[getPostThread] Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[getPostThread] Raw response: \(jsonString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BlueSkyError.networkError
        }
        
        do {
            return try JSONDecoder().decode(PostThreadResponse.self, from: data)
        } catch {
            print("[getPostThread] Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type \(type): \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found for type \(type): \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            throw error
        }
    }
    
    // MARK: - Post Creation Methods
    func createReply(text: String, parentUri: String, parentCid: String, rootUri: String, rootCid: String) async throws -> CreatePostResponse {
        guard let session = await authService.currentSession else {
            throw BlueSkyError.noActiveSession
        }
        
        let endpoint = "com.atproto.repo.createRecord"
        let url = URL(string: baseURL + endpoint)!
        
        let body: [String: Any] = [
            "repo": session.did,
            "collection": "app.bsky.feed.post",
            "record": [
                "$type": "app.bsky.feed.post",
                "text": text,
                "reply": [
                    "root": [
                        "uri": rootUri,
                        "cid": rootCid
                    ],
                    "parent": [
                        "uri": parentUri,
                        "cid": parentCid
                    ]
                ],
                "createdAt": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessJwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BlueSkyError.networkError
        }
        
        return try JSONDecoder().decode(CreatePostResponse.self, from: data)
    }
}

// MARK: - Response Models
struct TimelineResponse: Codable {
    let cursor: String?
    let feed: [FeedViewPost]
}

struct LikeResponse: Codable {
    let uri: String
    let cid: String
}

struct RepostResponse: Codable {
    let uri: String
    let cid: String
}

// MARK: - Thread Response Models
struct PostThreadResponse: Codable {
    let thread: ThreadViewPost
    
    enum CodingKeys: String, CodingKey {
        case thread
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("[PostThreadResponse] Starting decode")
        
        do {
            self.thread = try container.decode(ThreadViewPost.self, forKey: .thread)
            print("[PostThreadResponse] Successfully decoded thread")
        } catch {
            print("[PostThreadResponse] Failed to decode thread: \(error)")
            // Try to get more info about what's in the container
            if let rawThread = try? container.decode(DebugAnyCodable.self, forKey: .thread) {
                print("[PostThreadResponse] Raw thread data: \(rawThread)")
            }
            throw error
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(thread, forKey: .thread)
    }
}

// Helper to decode any JSON value for debugging
struct DebugAnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var dict = [String: Any]()
            for key in container.allKeys {
                if let val = try? container.decode(DebugAnyCodable.self, forKey: key) {
                    dict[key.stringValue] = val.value
                }
            }
            self.value = dict
        } else if var container = try? decoder.unkeyedContainer() {
            var array = [Any]()
            while !container.isAtEnd {
                if let val = try? container.decode(DebugAnyCodable.self) {
                    array.append(val.value)
                }
            }
            self.value = array
        } else if let container = try? decoder.singleValueContainer() {
            if let val = try? container.decode(Bool.self) {
                self.value = val
            } else if let val = try? container.decode(Int.self) {
                self.value = val
            } else if let val = try? container.decode(Double.self) {
                self.value = val
            } else if let val = try? container.decode(String.self) {
                self.value = val
            } else {
                self.value = NSNull()
            }
        } else {
            self.value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        // Not needed for debugging
    }
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.stringValue = String(intValue)
            self.intValue = intValue
        }
    }
}

struct CreatePostResponse: Codable {
    let uri: String
    let cid: String
}

// Helper for decoding arrays where some elements might fail
struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

class ThreadViewPost: Codable {
    let post: FeedViewPost
    let parent: ThreadViewPost?
    let replies: [ThreadViewPost]?
    let viewer: BSViewer?
    let blocked: Bool?
    let notFound: Bool?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case post
        case parent
        case replies
        case viewer
        case blocked
        case notFound
        case type = "$type"
    }
    
    init(post: FeedViewPost, 
         parent: ThreadViewPost? = nil, 
         replies: [ThreadViewPost]? = nil, 
         viewer: BSViewer? = nil, 
         blocked: Bool? = nil, 
         notFound: Bool? = nil) {
        self.post = post
        self.parent = parent
        self.replies = replies
        self.viewer = viewer
        self.blocked = blocked
        self.notFound = notFound
        self.type = nil
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle the $type field
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        
        // Debug logging
        print("[ThreadViewPost] Decoding with type: \(self.type ?? "nil")")
        
        // Check if this is a blocked or not found post
        if let type = self.type {
            if type.contains("blockedPost") {
                self.blocked = true
                self.notFound = false
                // For blocked posts, we might not have a post object
                self.post = FeedViewPost.mockPost
                self.parent = nil
                self.replies = nil
                self.viewer = nil
                return
            } else if type.contains("notFoundPost") {
                self.notFound = true
                self.blocked = false
                // For not found posts, we might not have a post object
                self.post = FeedViewPost.mockPost
                self.parent = nil
                self.replies = nil
                self.viewer = nil
                return
            }
        }
        
        // Normal decoding
        do {
            print("[ThreadViewPost] About to decode post data")
            
            // The "post" field in thread response contains direct BSPost data,
            // not a FeedViewPost. We need to decode it as BSPost and wrap it.
            let bsPost = try container.decode(BSPost.self, forKey: .post)
            
            // Create a FeedViewPost wrapper
            self.post = FeedViewPost(
                post: bsPost,
                reply: nil,  // Thread responses don't include reply context at this level
                reason: nil,  // No reason in thread responses
                embed: bsPost.embed,  // Use the embed from BSPost
                viewer: bsPost.viewer,  // Use the viewer from BSPost
                labels: bsPost.labels  // Use the labels from BSPost
            )
            
            print("[ThreadViewPost] Successfully decoded post as BSPost and wrapped in FeedViewPost")
        } catch {
            print("[ThreadViewPost] Error decoding post: \(error)")
            
            // Try to see what's in the post field
            if let rawPost = try? container.decode(DebugAnyCodable.self, forKey: .post) {
                print("[ThreadViewPost] Raw post data type: \(Swift.type(of: rawPost.value))")
                print("[ThreadViewPost] Raw post data: \(rawPost.value)")
            }
            
            throw error
        }
        
        self.parent = try container.decodeIfPresent(ThreadViewPost.self, forKey: .parent)
        
        // Decode replies array with error handling
        if container.contains(.replies) {
            var repliesArray = [ThreadViewPost]()
            if let repliesContainer = try? container.decode([ThreadViewPost].self, forKey: .replies) {
                repliesArray = repliesContainer
            } else {
                print("[ThreadViewPost] Failed to decode replies array, trying individual items")
                // Try to decode what we can
                if let rawReplies = try? container.decode([FailableDecodable<ThreadViewPost>].self, forKey: .replies) {
                    repliesArray = rawReplies.compactMap { $0.base }
                }
            }
            self.replies = repliesArray.isEmpty ? nil : repliesArray
        } else {
            self.replies = nil
        }
        
        self.viewer = try container.decodeIfPresent(BSViewer.self, forKey: .viewer)
        self.blocked = try container.decodeIfPresent(Bool.self, forKey: .blocked) ?? false
        self.notFound = try container.decodeIfPresent(Bool.self, forKey: .notFound) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // When encoding, we need to encode just the BSPost data, not the full FeedViewPost
        try container.encode(post.post, forKey: .post)
        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encodeIfPresent(replies, forKey: .replies)
        try container.encodeIfPresent(viewer, forKey: .viewer)
        try container.encodeIfPresent(blocked, forKey: .blocked)
        try container.encodeIfPresent(notFound, forKey: .notFound)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
