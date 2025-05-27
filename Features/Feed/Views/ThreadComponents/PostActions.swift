import SwiftUI

struct PostActions: View {
    let post: FeedViewPost
    @Binding var isLiked: Bool
    @Binding var isReplied: Bool
    @Binding var isReposted: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ActionButton(
                icon: isReposted ? "arrow.2.squarepath.fill" : "arrow.2.squarepath",
                count: post.post.repostCount,
                isActive: isReposted,
                color: .voxPrimary
            ) {
                isReposted.toggle()
            }
            
            ActionButton(
                icon: isReplied ? "bubble.left.fill" : "bubble.left",
                count: post.post.replyCount,
                isActive: isReplied,
                color: .voxDetail
            ) {
                isReplied.toggle()
            }
            
            ActionButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: post.post.likeCount,
                isActive: isLiked,
                color: .voxSecondary
            ) {
                isLiked.toggle()
            }
        }
    }
} 
