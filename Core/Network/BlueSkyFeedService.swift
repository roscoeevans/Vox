import Foundation

protocol FeedServiceProtocol {
    func getTimeline(cursor: String?) async throws -> TimelineResponse
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
}

// MARK: - Response Models
struct TimelineResponse: Codable {
    let cursor: String?
    let feed: [FeedViewPost]
}
