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
            if let quotedEmbed = extractQuotedEmbed() {
                if quotedEmbed.value?.text != nil || quotedEmbed.post?.author.displayName != nil || quotedEmbed.post?.author.handle != "" {
                    QuotedPostView(quotedEmbed: quotedEmbed)
                }
            }
            
            // --- VIDEO SUPPORT ---
            if let videoView = extractVideoView() {
                VideoPlayerView(
                    videoURL: videoView.url,
                    aspectRatio: videoView.aspectRatio,
                    thumbnail: videoView.thumbnail,
                    alt: videoView.alt
                )
            }
            
            // --- EXTERNAL LINK SUPPORT ---
            if let external = (post.embed ?? post.post.record.embed)?.external {
                if isYouTubeURL(external.uri) {
                    YouTubeLinkCard(external: external, authorDID: post.author.did)
                } else {
                    ExternalLinkCard(external: external, authorDID: post.author.did)
                }
            }
            
            // Images should always be the last element, so their bottom aligns with post actions
            if let images = post.embed?.images ?? post.post.record.embed?.images {
                PostImages(images: images)
                    .environment(\.postAuthorDID, post.author.did)
            }
        }
        // If there are no images, the bottom of the content will be text or quoted post
    }
    
    // Helper to extract video view data
    private func extractVideoView() -> (url: URL, aspectRatio: AspectRatio?, thumbnail: String?, alt: String?)? {
        // First check the top-level embed on FeedViewPost
        if let embed = post.embed, embed.type == "app.bsky.embed.video#view" {
            if let playlist = embed.playlist,
               let videoURL = URL(string: playlist) {
                return (url: videoURL, aspectRatio: embed.aspectRatio, thumbnail: embed.thumbnail, alt: embed.alt)
            }
        }
        
        // Then check the post's embed
        if let embed = post.post.embed, embed.type == "app.bsky.embed.video#view" {
            if let playlist = embed.playlist,
               let videoURL = URL(string: playlist) {
                return (url: videoURL, aspectRatio: embed.aspectRatio, thumbnail: embed.thumbnail, alt: embed.alt)
            }
        }
        
        // Finally, check record embed for direct video (no playlist URL available)
        if let embed = post.post.record.embed, embed.type == "app.bsky.embed.video" {
            if let video = embed.video,
               let videoRef = video.video.ref?.link {
                let videoURL = constructBlobURL(cid: videoRef, did: post.author.did)
                return (url: videoURL, aspectRatio: video.aspectRatio, thumbnail: video.thumb, alt: video.alt)
            }
        }
        
        return nil
    }
    
    // Helper function to check if URL is a YouTube link
    private func isYouTubeURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased() else { return false }
        
        // Check for various YouTube domains
        return host.contains("youtube.com") || 
               host.contains("youtu.be") || 
               host.contains("m.youtube.com") ||
               host.contains("youtube-nocookie.com")
    }
    
    // Helper function to construct blob URL
    private func constructBlobURL(cid: String, did: String) -> URL {
        return URL(string: "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=\(did)&cid=\(cid)")!
    }
    
    // Helper to extract quoted/embedded post
    private func extractQuotedEmbed() -> BSEmbedRecordView? {
        // Check for app.bsky.embed.record or app.bsky.embed.recordWithMedia
        // IMPORTANT: For timeline posts, quotes are at post.embed level, not post.post.embed!
        let embed = post.embed ?? post.post.embed ?? post.post.record.embed
        
        guard let type = embed?.type else {
            return nil
        }
        
        // Handle view types from API responses
        if type == "app.bsky.embed.record#view" {
            // For view types, the data is in embed.record
            if let embed = embed,
               let record = embed.record {
                // Check if we have a nested BSEmbedRecordView
                if let recordView = record.record {
                    return recordView
                }
                
                // Check if we have the data directly in the record
                if record.author != nil && (record.value != nil || record.uri != nil) {
                    // Create a BSEmbedRecordView from the record data
                    return BSEmbedRecordView(
                        type: type,
                        uri: record.uri ?? "",
                        cid: record.cid ?? "",
                        post: BSPost(
                            uri: record.uri ?? "",
                            cid: record.cid ?? "",
                            author: record.author!,
                            record: record.value ?? BSPostRecord(type: nil, text: "", createdAt: "", embed: nil, reply: nil, langs: nil, facets: nil),
                            replyCount: record.replyCount ?? 0,
                            repostCount: record.repostCount ?? 0,
                            likeCount: record.likeCount ?? 0,
                            quoteCount: record.quoteCount ?? 0,
                            indexedAt: record.indexedAt ?? "",
                            viewer: nil,
                            labels: nil,
                            embed: nil
                        ),
                        value: record.value,
                        labels: nil,
                        likeCount: record.likeCount,
                        replyCount: record.replyCount,
                        repostCount: record.repostCount,
                        quoteCount: record.quoteCount,
                        indexedAt: record.indexedAt,
                        embeds: record.embeds,
                        viewer: nil
                    )
                }
            }
        }
        
        // Handle regular embed types
        if type == "app.bsky.embed.record" {
            if let record = embed?.record {
                // The API might return the data directly in the record object
                // Try to create a BSEmbedRecordView from available data
                if record.record?.uri != nil,
                   record.record?.post?.author != nil {
                    return record.record
                }
            }
        }
        
        // Handle recordWithMedia
        if type == "app.bsky.embed.recordWithMedia" {
            if let record = embed?.record {
                return record.record
            }
        }
        
        return nil
    }
}

// External link view component - REMOVED (now using ExternalLinkCard) 