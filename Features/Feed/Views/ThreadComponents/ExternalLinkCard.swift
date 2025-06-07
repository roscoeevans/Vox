import SwiftUI

struct ExternalLinkCard: View {
    let external: BSEmbedExternal
    let authorDID: String?
    @State private var imageLoadFailed = false
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail section with fixed aspect ratio
            ZStack {
                // Background placeholder that maintains consistent size
                Rectangle()
                    .fill(Color(uiColor: .tertiarySystemBackground))
                    .aspectRatio(16/9, contentMode: .fit) // Standard widescreen thumbnail ratio
                    .frame(maxWidth: .infinity)
                
                if let thumbUrl = thumbnailURL, !imageLoadFailed {
                    AsyncImage(url: URL(string: thumbUrl)) { phase in
                        switch phase {
                        case .empty:
                            // Loading state - show placeholder content
                            thumbnailPlaceholderContent
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill) // Fill to cover the entire area
                                .frame(maxWidth: .infinity)
                                .aspectRatio(16/9, contentMode: .fit) // Maintain aspect ratio
                                .clipped() // Crop any overflow
                        case .failure(let error):
                            thumbnailPlaceholderContent
                                .onAppear { 
                                    imageLoadFailed = true
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
                
                // Website URL
                if let url = URL(string: external.uri), let host = url.host {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(host)
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.tertiary)
                }
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
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.3), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: external.uri) {
                UIApplication.shared.open(url)
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
