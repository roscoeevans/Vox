import SwiftUI
// ... existing code ...
// Place PostContent struct and its extractQuotedEmbed helper here.
// ... existing code ...

struct PostContent: View {
    let post: FeedViewPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.post.record.text)
                .font(.body)
            
            // Check both post.embed and post.post.record.embed for images
            if let images = post.embed?.images ?? post.post.record.embed?.images {
                PostImages(images: images)
                    .environment(\.postAuthorDID, post.author.did)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // --- QUOTE/EMBEDDED THREAD SUPPORT ---
            if let quotedEmbed = extractQuotedEmbed(),
               (quotedEmbed.value?.text != nil || quotedEmbed.post?.author.displayName != nil || quotedEmbed.post?.author.handle != "") {
                QuotedPostView(quotedEmbed: quotedEmbed)
            }
        }
    }
    
    // Helper to extract quoted/embedded post
    private func extractQuotedEmbed() -> BSEmbedRecordView? {
        // Check for app.bsky.embed.record or app.bsky.embed.recordWithMedia
        let embed = post.embed ?? post.post.record.embed
        guard let type = embed?.type else { return nil }
        if type == "app.bsky.embed.record" {
            return embed?.record?.record
        } else if type == "app.bsky.embed.recordWithMedia" {
            return embed?.record?.record
        }
        return nil
    }
} 