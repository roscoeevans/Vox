import SwiftUI
import UIKit

struct RepliesView: View {
    let post: FeedViewPost
    let feedService: FeedServiceProtocol
    
    @Environment(\.dismiss) private var dismiss
    @State private var thread: ThreadViewPost?
    @State private var isLoading = true
    @State private var error: Error?
    @State private var replyText = ""
    @State private var isPostingReply = false
    @FocusState private var isReplyFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.voxBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.voxSkyBlue)
                        .scaleEffect(1.5)
                } else if let error = error {
                    ErrorView(error: error) {
                        Task {
                            await loadThread()
                        }
                    }
                } else if let thread = thread {
                    VStack(spacing: 0) {
                        // Scrollable content
                        ScrollView {
                            VStack(spacing: 0) {
                                // Parent post with custom layout
                                ParentPostView(post: thread.post, feedService: feedService)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                
                                Divider()
                                    .background(Color.voxText.opacity(0.1))
                                
                                // Replies using PostView
                                if let replies = thread.replies, !replies.isEmpty {
                                    LazyVStack(spacing: 0) {
                                        ForEach(replies.indices, id: \.self) { index in
                                            PostView(post: replies[index].post, feedService: feedService)
                                            
                                            if index < replies.count - 1 {
                                                Divider()
                                                    .background(Color.voxText.opacity(0.1))
                                            }
                                        }
                                    }
                                } else {
                                    EmptyRepliesView()
                                        .padding(.vertical, 40)
                                }
                            }
                        }
                        
                        // Reply input field
                        ReplyInputView(
                            replyText: $replyText,
                            isPostingReply: $isPostingReply,
                            isReplyFieldFocused: _isReplyFieldFocused,
                            onSubmit: {
                                Task {
                                    await postReply()
                                }
                            }
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Replies")
                        .font(.headline)
                        .foregroundColor(.voxText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.voxText)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
        .task {
            await loadThread()
        }
    }
    
    private func loadThread() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await feedService.getPostThread(
                uri: post.post.uri,
                depth: 6,
                parentHeight: 0
            )
            thread = response.thread
        } catch {
            print("[RepliesView] Error loading thread: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    private func postReply() async {
        guard !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let thread = thread else { return }
        
        isPostingReply = true
        
        do {
            // Determine root post (for thread continuity)
            let rootUri = thread.post.post.record.reply?.root.uri ?? thread.post.post.uri
            let rootCid = thread.post.post.record.reply?.root.cid ?? thread.post.post.cid
            
            _ = try await feedService.createReply(
                text: replyText,
                parentUri: thread.post.post.uri,
                parentCid: thread.post.post.cid,
                rootUri: rootUri,
                rootCid: rootCid
            )
            
            // Clear the reply text
            replyText = ""
            isReplyFieldFocused = false
            
            // Reload the thread to show the new reply
            await loadThread()
        } catch {
            print("[RepliesView] Error posting reply: \(error)")
            // TODO: Show error alert
        }
        
        isPostingReply = false
    }
}

// Custom parent post view with horizontal action buttons
struct ParentPostView: View {
    let post: FeedViewPost
    let feedService: FeedServiceProtocol
    @State private var showReplies = false
    @State private var animationTrigger = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author info
            HStack(spacing: 12) {
                if let avatarUrl = post.author.avatar {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(LinearGradient.voxSubtleGradient.opacity(0.3))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(LinearGradient.voxSubtleGradient.opacity(0.2), lineWidth: 1)
                    )
                } else {
                    Circle()
                        .fill(LinearGradient.voxSubtleGradient.opacity(0.3))
                        .frame(width: 48, height: 48)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author.displayName ?? post.author.handle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.voxText)
                    
                    Text("@\(post.author.handle)")
                        .font(.system(size: 14))
                        .foregroundColor(.voxText.opacity(0.6))
                }
                
                Spacer()
                
                Text(formatRelativeTime(post.post.indexedAt))
                    .font(.system(size: 14))
                    .foregroundColor(.voxText.opacity(0.6))
            }
            
            // Post content
            Text(post.post.record.text)
                .font(.system(size: 16))
                .foregroundColor(.voxText)
                .lineSpacing(4)
            
            // Media if present
            if let embed = post.embed {
                MediaEmbedView(embed: embed, authorDID: post.author.did)
                    .padding(.top, 8)
            }
            
            // Horizontal action bar with gradient touches
            HStack(spacing: 0) {
                // Share button (far left)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        animationTrigger.toggle()
                    }
                    // TODO: Implement share functionality
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(LinearGradient.voxCoolGradient)
                        .symbolEffect(.pulse, value: animationTrigger)
                }
                .frame(maxWidth: .infinity)
                
                // Reply button
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                        Text("\(post.post.replyCount)")
                            .font(.system(size: 14, design: .rounded))
                    }
                    .foregroundColor(.voxPeriwinkle)
                }
                .frame(maxWidth: .infinity)
                
                // Repost button
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: post.post.viewer?.repost != nil ? "arrow.2.squarepath.fill" : "arrow.2.squarepath")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                        Text("\(post.post.repostCount)")
                            .font(.system(size: 14, design: .rounded))
                    }
                    .foregroundStyle(post.post.viewer?.repost != nil ? LinearGradient(
                        colors: [.voxSkyBlue, .voxBabyBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient(
                        colors: [.voxText.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                }
                .frame(maxWidth: .infinity)
                
                // Like button
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: post.post.viewer?.like != nil ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                        Text("\(post.post.likeCount)")
                            .font(.system(size: 14, design: .rounded))
                    }
                    .foregroundStyle(post.post.viewer?.like != nil ? LinearGradient.voxWarmGradient : LinearGradient(
                        colors: [.voxText.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(LinearGradient.voxSubtleGradient.opacity(0.2), lineWidth: 0.5)
                    )
            )
        }
    }
    
    private func formatRelativeTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return ""
        }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years)y"
        } else if let months = components.month, months > 0 {
            return "\(months)mo"
        } else if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}

// Media embed view for parent post
struct MediaEmbedView: View {
    let embed: BSEmbed
    let authorDID: String?
    
    init(embed: BSEmbed, authorDID: String? = nil) {
        self.embed = embed
        self.authorDID = authorDID
    }
    
    var body: some View {
        if let images = embed.images {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(images.indices, id: \.self) { index in
                        if let imageUrl = images[index].fullsize {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.voxText.opacity(0.1))
                            }
                            .frame(height: 200)
                            .frame(maxWidth: images.count == 1 ? .infinity : 300)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        } else if let external = embed.external {
            // Use the new ExternalLinkCard component
            ExternalLinkCard(external: external, authorDID: authorDID)
        }
    }
}

// MARK: - Reply Input View
private struct ReplyInputView: View {
    @Binding var replyText: String
    @Binding var isPostingReply: Bool
    @FocusState var isReplyFieldFocused: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(LinearGradient.voxSubtleGradient.opacity(0.3))
            
            HStack(alignment: .bottom, spacing: 12) {
                // Text field with gradient accent
                TextField("Add a reply...", text: $replyText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.voxText)
                    .focused($isReplyFieldFocused)
                    .lineLimit(1...5)
                    .padding(.vertical, 8)
                    .disabled(isPostingReply)
                
                // Send button with gradient
                Button(action: onSubmit) {
                    if isPostingReply {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.voxSkyBlue)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(replyText.isEmpty ? AnyShapeStyle(Color.voxText.opacity(0.3)) : AnyShapeStyle(LinearGradient.voxCoolGradient))
                    }
                }
                .disabled(replyText.isEmpty || isPostingReply)
                .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        LinearGradient.voxSubtleGradient.opacity(0.1)
                    )
            )
        }
    }
}

// MARK: - Empty Replies View
private struct EmptyRepliesView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Gradient glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.voxPeriwinkle.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(LinearGradient.voxCoolGradient)
            }
            
            Text("No replies... yet!")
                .font(.headline)
                .foregroundColor(.voxText)
            
            Text("Be the spark ✨")
                .font(.subheadline)
                .foregroundStyle(LinearGradient.voxSubtleGradient)
        }
    }
}

// MARK: - Error View
private struct ErrorView: View {
    let error: Error
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Gradient glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.voxCoralRed.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(LinearGradient.voxWarmGradient)
            }
            
            Text("Failed to load replies")
                .font(.headline)
                .foregroundColor(.voxText)
            
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.voxText.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retry) {
                Text("Try Again")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(LinearGradient.voxWarmGradient)
                    .clipShape(Capsule())
                    .shadow(color: Color.voxCoralRed.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}

// MARK: - Preview
struct RepliesView_Previews: PreviewProvider {
    static var previews: some View {
        RepliesView(
            post: FeedViewPost.mockPost,
            feedService: BlueSkyFeedService(authService: BlueSkyAuthService())
        )
    }
} 