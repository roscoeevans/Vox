import Foundation

struct Post: Identifiable {
    let id: String
    let author: Profile
    let content: String
    let createdAt: Date
    var likes: Int
    var reposts: Int
    var replies: Int
    
    static let mockPosts: [Post] = [
        Post(
            id: "1",
            author: Profile(
                id: "1",
                handle: "alice",
                displayName: "Alice Smith"
            ),
            content: "Just launched my new app! 🚀",
            createdAt: Date(),
            likes: 42,
            reposts: 12,
            replies: 5
        ),
        Post(
            id: "2",
            author: Profile(
                id: "2",
                handle: "bob",
                displayName: "Bob Johnson"
            ),
            content: "Beautiful day for coding! ☀️",
            createdAt: Date().addingTimeInterval(-3600),
            likes: 24,
            reposts: 8,
            replies: 3
        )
    ]
} 