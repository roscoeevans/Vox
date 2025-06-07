import SwiftUI

struct AuthorHandleView: View {
    let author: BSAuthor
    let isCompact: Bool
    @State private var showFullHandle = false
    
    init(author: BSAuthor, isCompact: Bool = false) {
        self.author = author
        self.isCompact = isCompact
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(author.formattedHandle)
                .font(isCompact ? .voxCaption() : .voxHeadline())
                .foregroundColor(isCompact ? .secondary : .primary)
            
            if author.isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .font(isCompact ? .system(size: 10) : .caption)
                    .onTapGesture {
                        showFullHandle = true
                    }
            }
        }
        .popover(isPresented: $showFullHandle) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Verified Handle")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(author.handle)
                        .font(.body)
                        .fontDesign(.monospaced)
                }
                
                Text("This account uses a custom domain")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}

// MARK: - Preview
#Preview("Verified Handle") {
    VStack(spacing: 20) {
        // Regular size
        AuthorHandleView(
            author: BSAuthor(
                did: "sample-did",
                handle: "news.nytimes.com",
                displayName: "The New York Times",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            )
        )
        
        // Compact size
        AuthorHandleView(
            author: BSAuthor(
                did: "sample-did",
                handle: "news.nytimes.com",
                displayName: "The New York Times",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            isCompact: true
        )
        
        AuthorHandleView(
            author: BSAuthor(
                did: "sample-did-2",
                handle: "alice.bsky.social",
                displayName: "Alice",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            )
        )
        
        AuthorHandleView(
            author: BSAuthor(
                did: "sample-did-3",
                handle: "senator.senate.gov",
                displayName: "Senator Smith",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            )
        )
    }
    .padding()
} 
