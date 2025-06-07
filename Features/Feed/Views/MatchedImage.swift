import SwiftUI

// Define MediaItem struct to hold image information
struct MediaItem {
    let id: String
    let url: URL
}

struct MatchedImageContainer: View {
    let item: MediaItem
    let namespace: Namespace.ID
    @Binding var selectedMedia: String?
    let aspectRatio: CGFloat
    let contentMode: ContentMode
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let corners: UIRectCorner
    
    var body: some View {
        if selectedMedia == item.id {
            // Placeholder when image is selected
            Color.clear
                .frame(width: width, height: height)
                .clipShape(SelectiveRoundedCorners(corners: corners, radius: cornerRadius))
        } else {
            // The actual image with proper animation anchor
            GeometryReader { geometry in
                CachedAsyncImage(url: item.url, contentMode: contentMode)
                    .aspectRatio(aspectRatio, contentMode: contentMode)
                    .frame(width: width, height: height)
                    .clipped()
                    .clipShape(SelectiveRoundedCorners(corners: corners, radius: cornerRadius))
                    .matchedGeometryEffect(
                        id: item.id,
                        in: namespace,
                        properties: .frame,
                        anchor: .center,
                        isSource: true
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .frame(width: width, height: height)
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    selectedMedia = item.id
                }
            }
        }
    }
} 
