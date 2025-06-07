import SwiftUI

struct QuotedPostView: View {
    let quotedEmbed: BSEmbedRecordView

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let post = quotedEmbed.post {
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
                    VStack(alignment: .leading, spacing: 2) {
                        if let displayName = post.author.displayName, !displayName.isEmpty {
                            Text(displayName)
                                .font(.voxSubheadline())
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            AuthorHandleView(author: post.author, isCompact: true)
                        } else {
                            AuthorHandleView(author: post.author)
                        }
                    }
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
                if let images = quotedEmbed.embeds?.compactMap({ $0.images }).flatMap({ $0 }), !images.isEmpty {
                    PostImages(images: images)
                        .environment(\.postAuthorDID, post.author.did)
                        .padding(.top, 4)
                }
                // Optionally, show quoted post's like/reply/repost counts (Twitter does not, so omit for now)
            } else {
                // Unavailable/deleted post
                Text("This post is unavailable")
                    .font(.voxSubheadline())
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 8)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .padding(.top, 8) // Spacing from main post content
    }
} 
