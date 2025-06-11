import SwiftUI

struct QuotedPostView: View {
    let quotedEmbed: BSEmbedRecordView

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let post = quotedEmbed.post {
                // Header and text content with padding
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        if let avatar = post.author.avatar, let url = URL(string: avatar) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 28, height: 28)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(.secondary)
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                        }
                        
                        AuthorHandleView(author: post.author)
                    }
                    
                    if let text = quotedEmbed.value?.text, !text.isEmpty {
                        Text(text)
                            .font(.voxBody())
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    } else if !post.record.text.isEmpty {
                        Text(post.record.text)
                            .font(.voxBody())
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    }
                }
                .padding(12)
                
                // Images without padding - stretch to edges
                if let images = quotedEmbed.embeds?.compactMap({ $0.images }).flatMap({ $0 }), !images.isEmpty {
                    PostImages(images: images)
                        .environment(\.postAuthorDID, post.author.did)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 12,
                                topTrailingRadius: 0
                            )
                        )
                }
            } else {
                // Unavailable/deleted post
                Text("This post is unavailable")
                    .font(.voxSubheadline())
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .padding(.top, 8) // Spacing from main post content
    }
}

// Preview helper for test images
struct PreviewImageView: View {
    let color: Color
    let text: String
    
    var body: some View {
        ZStack {
            color
            Text(text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview 1: Available post with text
        QuotedPostView(
            quotedEmbed: BSEmbedRecordView(
                type: "app.bsky.embed.record#view",
                uri: "at://did:plc:example/app.bsky.feed.post/123",
                cid: "bafyreie5cvv4h45feadgeuwhbcutmh6t2ceseocckahdoe6uat64zmz5ua",
                post: BSPost(
                    uri: "at://did:plc:example/app.bsky.feed.post/123",
                    cid: "bafyreie5cvv4h45feadgeuwhbcutmh6t2ceseocckahdoe6uat64zmz5ua",
                    author: BSAuthor(
                        did: "did:plc:example",
                        handle: "alice.bsky.social",
                        displayName: "Alice Johnson",
                        avatar: "https://picsum.photos/200", // Using picsum for preview
                        createdAt: "2023-01-01T00:00:00.000Z"
                    ),
                    record: BSPostRecord(
                        text: "This is a quoted post with some interesting content that demonstrates how quotes appear in the feed.",
                        createdAt: "2024-01-15T10:30:00.000Z"
                    ),
                    replyCount: 5,
                    repostCount: 12,
                    likeCount: 42,
                    quoteCount: 3,
                    indexedAt: "2024-01-15T10:30:00.000Z"
                ),
                value: BSPostRecord(
                    text: "This is a quoted post with some interesting content that demonstrates how quotes appear in the feed.",
                    createdAt: "2024-01-15T10:30:00.000Z"
                ),
                labels: nil,
                likeCount: 42,
                replyCount: 5,
                repostCount: 12,
                quoteCount: 3,
                indexedAt: "2024-01-15T10:30:00.000Z",
                embeds: nil,
                viewer: nil
            )
        )
        
        // Preview 2: Post without avatar
        QuotedPostView(
            quotedEmbed: BSEmbedRecordView(
                type: "app.bsky.embed.record#view",
                uri: "at://did:plc:example2/app.bsky.feed.post/456",
                cid: "bafyreie5cvv4h45feadgeuwhbcutmh6t2ceseocckahdoe6uat64zmz5ub",
                post: BSPost(
                    uri: "at://did:plc:example2/app.bsky.feed.post/456",
                    cid: "bafyreie5cvv4h45feadgeuwhbcutmh6t2ceseocckahdoe6uat64zmz5ub",
                    author: BSAuthor(
                        did: "did:plc:example2",
                        handle: "user.bsky.social",
                        displayName: nil,
                        avatar: nil,
                        createdAt: "2023-01-01T00:00:00.000Z"
                    ),
                    record: BSPostRecord(
                        text: "A post from someone without an avatar.",
                        createdAt: "2024-01-15T11:00:00.000Z"
                    ),
                    replyCount: 0,
                    repostCount: 1,
                    likeCount: 3,
                    quoteCount: 0,
                    indexedAt: "2024-01-15T11:00:00.000Z"
                ),
                value: BSPostRecord(
                    text: "A post from someone without an avatar.",
                    createdAt: "2024-01-15T11:00:00.000Z"
                ),
                labels: nil,
                likeCount: 3,
                replyCount: 0,
                repostCount: 1,
                quoteCount: 0,
                indexedAt: "2024-01-15T11:00:00.000Z",
                embeds: nil,
                viewer: nil
            )
        )
        
        // Preview 3: Post with test image (colored rectangle)
        VStack(alignment: .leading, spacing: 0) {
            // Header and text content with padding
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.blue)
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                    
                    Text("@photographer.bsky.social")
                        .font(.voxSubheadline())
                        .foregroundColor(.secondary)
                }
                
                Text("Check out these amazing photos from today's shoot!")
                    .font(.voxBody())
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
            .padding(12)
            
            // Test image that stretches to edges
            PreviewImageView(color: .blue, text: "Test Image")
                .frame(height: 200)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 0
                    )
                )
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .padding(.top, 8)
        
        // Preview 4: Unavailable/deleted post
        QuotedPostView(
            quotedEmbed: BSEmbedRecordView(
                type: "app.bsky.embed.record#view",
                uri: "at://did:plc:example4/app.bsky.feed.post/999",
                cid: "bafyreie5cvv4h45feadgeuwhbcutmh6t2ceseocckahdoe6uat64zmz5ud",
                post: nil,
                value: nil,
                labels: nil,
                likeCount: nil,
                replyCount: nil,
                repostCount: nil,
                quoteCount: nil,
                indexedAt: "2024-01-15T16:00:00.000Z",
                embeds: nil,
                viewer: nil
            )
        )
    }
    .padding()
    .background(Color(.systemBackground))
} 
