import SwiftUI

struct ExternalLinkCard: View {
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
            print("[ExternalLinkCard] Constructed blob URL: \(blobURL)")
            return blobURL
        }
        
        return nil
    }
    
    private func getFaviconURL(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let host = url.host else { return nil }
        
        // Try Google's favicon service as a fallback
        return "https://www.google.com/s2/favicons?domain=\(host)&sz=64"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Thumbnail section that fills the entire card
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
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                    .onAppear { isImageLoading = false }
                            case .failure(let error):
                                thumbnailPlaceholderContent
                                    .onAppear { 
                                        imageLoadFailed = true
                                        isImageLoading = false
                                        print("[ExternalLinkCard] Failed to load image from URL: \(thumbUrl)")
                                        print("[ExternalLinkCard] Error: \(error)")
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
                
                // Content overlay with blur background
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(external.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Website URL with favicon
                    if let url = URL(string: external.uri), let host = url.host {
                        HStack(spacing: 6) {
                            // Favicon
                            AsyncImage(url: URL(string: getFaviconURL(from: external.uri) ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                default:
                                    Image(systemName: "globe")
                                        .font(.system(size: 12))
                                        .frame(width: 16, height: 16)
                                }
                            }
                            
                            Text(host)
                                .font(.system(size: 12))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    // Blur effect background
                    ZStack {
                        // Ultra thin material for the blur effect
                        Rectangle()
                            .fill(.ultraThinMaterial)
                        
                        // Slight dark overlay to ensure text readability
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                    }
                )
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 0,
                    style: .continuous
                ))
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
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
                    Label("Open in Safari", systemImage: "safari")
                }
                
                ShareLink(item: url) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
    private var thumbnailPlaceholderContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "link")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            
            if let url = URL(string: external.uri), let host = url.host {
                Text(host)
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var thumbnailPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color(uiColor: .tertiarySystemBackground))
            
            thumbnailPlaceholderContent
        }
    }
}

// Preview provider
struct ExternalLinkCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // With thumbnail
            ExternalLinkCard(
                external: createMockExternal(
                    uri: "https://example.com/article",
                    title: "Example Article Title That Might Be Long",
                    description: "This is a description of the article that provides more context about what the link contains.",
                    thumb: "https://via.placeholder.com/600x400"
                ),
                authorDID: "did:plc:example"
            )
            
            // Without thumbnail
            ExternalLinkCard(
                external: createMockExternal(
                    uri: "https://example.com/article",
                    title: "Article Without Thumbnail",
                    description: "This article doesn't have a preview image.",
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
