import SwiftUI

struct YouTubeLinkCard: View {
    let external: BSEmbedExternal
    let authorDID: String?
    @State private var imageLoadFailed = false
    @State private var isImageLoading = true
    @State private var faviconURL: String?
    @State private var isPressed = false
    
    init(external: BSEmbedExternal, authorDID: String? = nil) {
        self.external = external
        self.authorDID = authorDID
    }
    
    private var thumbnailURL: String? {
        // First try the direct thumb string
        if let thumb = external.thumb {
            return thumb
        }
        
        // If thumb is nil, check if we have a thumbBlob with a ref link
        if let thumbBlob = external.thumbBlob,
           let ref = thumbBlob.ref,
           let link = ref.link,
           let did = authorDID {
            // Construct the blob URL
            // Format: https://cdn.bsky.app/img/feed_thumbnail/plain/{did}/{cid}@jpeg
            let blobURL = "https://cdn.bsky.app/img/feed_thumbnail/plain/\(did)/\(link)@jpeg"
            print("[YouTubeLinkCard] Constructed blob URL: \(blobURL)")
            return blobURL
        }
        
        return nil
    }
    
    private func getFaviconURL(from urlString: String) -> String? {
        // YouTube always uses the same favicon
        return "https://www.youtube.com/s/desktop/28b0985e/img/favicon_32x32.png"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail section with fixed aspect ratio
            GeometryReader { geometry in
                ZStack {
                    // Background placeholder that maintains consistent size
                    Rectangle()
                        .fill(Color(uiColor: .tertiarySystemBackground))
                    
                    if let thumbUrl = thumbnailURL, !imageLoadFailed {
                        AsyncImage(url: URL(string: thumbUrl)) { phase in
                            switch phase {
                            case .empty:
                                // Loading state with shimmer effect
                                ZStack {
                                    thumbnailPlaceholderContent
                                    if isImageLoading {
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0),
                                                        Color.white.opacity(0.3),
                                                        Color.white.opacity(0)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .animation(
                                                Animation.linear(duration: 1.5)
                                                    .repeatForever(autoreverses: false),
                                                value: isImageLoading
                                            )
                                    }
                                }
                                .onAppear { isImageLoading = true }
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill) // Fill to cover the entire area
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped() // Crop any overflow
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                    .onAppear { isImageLoading = false }
                            case .failure(let error):
                                thumbnailPlaceholderContent
                                    .onAppear { 
                                        imageLoadFailed = true
                                        isImageLoading = false
                                        print("[YouTubeLinkCard] Failed to load image from URL: \(thumbUrl)")
                                        print("[YouTubeLinkCard] Error: \(error)")
                                    }
                            @unknown default:
                                thumbnailPlaceholderContent
                            }
                        }
                    } else {
                        // No thumbnail available - show placeholder content
                        thumbnailPlaceholderContent
                    }
                }
            }
            .aspectRatio(16/9, contentMode: .fit) // Ensure consistent height
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16,
                style: .continuous
            ))
            
            // Content section
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(external.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // YouTube branding
                HStack(spacing: 6) {
                    // YouTube favicon
                    AsyncImage(url: URL(string: getFaviconURL(from: external.uri) ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        default:
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 12))
                                .frame(width: 16, height: 16)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Text("YouTube")
                        .font(.system(size: 12))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(.tertiary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0,
                style: .continuous
            ))
        }
        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion but respect horizontal constraints
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.3), lineWidth: 0.5)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: external.uri) {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                UIApplication.shared.open(url)
            }
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .contextMenu {
            if let url = URL(string: external.uri) {
                Button {
                    UIPasteboard.general.string = external.uri
                } label: {
                    Label("Copy Link", systemImage: "link")
                }
                
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Label("Open in YouTube", systemImage: "play.rectangle")
                }
                
                ShareLink(item: url) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
    private var thumbnailPlaceholderContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.red)
            
            Text("YouTube")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Preview provider
struct YouTubeLinkCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // YouTube video link
            YouTubeLinkCard(
                external: createMockExternal(
                    uri: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                    title: "Rick Astley - Never Gonna Give You Up (Official Video)",
                    description: "The official video for \"Never Gonna Give You Up\" by Rick Astley",
                    thumb: "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg"
                ),
                authorDID: "did:plc:example"
            )
            
            // YouTube shorts link
            YouTubeLinkCard(
                external: createMockExternal(
                    uri: "https://youtube.com/shorts/ABC123",
                    title: "Amazing Short Video",
                    description: "This is a YouTube Shorts video",
                    thumb: nil
                ),
                authorDID: "did:plc:example"
            )
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
    
    // Helper function to create mock BSEmbedExternal for previews
    static func createMockExternal(uri: String, title: String, description: String, thumb: String?) -> BSEmbedExternal {
        // Create a mock external object using the actual initializer
        // Since BSEmbedExternal requires decoding, we'll create a simple JSON and decode it
        let json = """
        {
            "uri": "\(uri)",
            "title": "\(title)",
            "description": "\(description)"
            \(thumb != nil ? ",\"thumb\": \"\(thumb!)\"" : "")
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try! decoder.decode(BSEmbedExternal.self, from: data)
    }
} 