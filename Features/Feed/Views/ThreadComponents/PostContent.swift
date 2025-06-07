import SwiftUI
import UIKit
// ... existing code ...
// Place PostContent struct and its extractQuotedEmbed helper here.
// ... existing code ...

struct PostContent: View {
    let post: FeedViewPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.post.record.text)
                .font(.body)
            
            // --- QUOTE/EMBEDDED THREAD SUPPORT ---
            if let quotedEmbed = extractQuotedEmbed(),
               (quotedEmbed.value?.text != nil || quotedEmbed.post?.author.displayName != nil || quotedEmbed.post?.author.handle != "") {
                QuotedPostView(quotedEmbed: quotedEmbed)
            }
            
            // --- EXTERNAL LINK SUPPORT ---
            if let external = (post.embed ?? post.post.record.embed)?.external {
                ExternalLinkCard(external: external, authorDID: post.author.did)
            }
            
            // Images should always be the last element, so their bottom aligns with post actions
            if let images = post.embed?.images ?? post.post.record.embed?.images {
                PostImages(images: images)
                    .environment(\.postAuthorDID, post.author.did)
            }
        }
        // If there are no images, the bottom of the content will be text or quoted post
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

// External link view component - REMOVED (now using ExternalLinkCard) 