import SwiftUI
import ATProtoKit

// MARK: - Main Component
struct ThreadView: View {
    let post: FeedViewPost
    
    // MARK: - Button States
    @State private var isLiked = false
    @State private var isReplied = false
    @State private var isReposted = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Post Header
            HStack {
                ProfileImage(avatarURLString: post.author.avatar)
                Text("@\(post.author.formattedHandle)")
                    .font(.headline)
            }
            HStack(alignment: .top, spacing: 16) {
                PostContent(post: post)
                PostActions(
                    post: post,
                    isLiked: $isLiked,
                    isReplied: $isReplied,
                    isReposted: $isReposted
                )
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

// MARK: - Content Component
private struct PostContent: View {
    let post: FeedViewPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.post.record.text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            // Check both post.embed and post.post.record.embed for images
            if let images = post.embed?.images ?? post.post.record.embed?.images {
                PostImages(images: images)
                    .environment(\.postAuthorDID, post.author.did)
            }
            
            // --- QUOTE/EMBEDDED THREAD SUPPORT ---
            if let quotedEmbed = extractQuotedEmbed(),
               (quotedEmbed.value?.text != nil || quotedEmbed.post?.author.displayName != nil || quotedEmbed.post?.author.handle != "") {
                QuotedPostView(quotedEmbed: quotedEmbed)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Bluesky Image View
private struct BlueskyImageView: View {
    let pds: String
    let did: String
    let cid: String
    let altText: String
    var body: some View {
        let url = blueskyBlobURL(pds: pds, did: did, cid: cid)
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel(Text(altText))
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(height: 200)
    }
    private func blueskyBlobURL(pds: String, did: String, cid: String) -> URL {
        let base = "https://\(pds)/xrpc/com.atproto.sync.getBlob"
        var comps = URLComponents(string: base)!
        comps.queryItems = [
            .init(name: "did", value: did),
            .init(name: "cid", value: cid)
        ]
        return comps.url!
    }
}

// MARK: - Images Component
private struct PostImages: View {
    let images: [BSEmbedImage]
    @State private var selectedImageIndex: IdentifiableInt? = nil
    @Environment(\.postAuthorDID) private var postAuthorDID
    let pds: String = "bsky.social" // TODO: Make dynamic if needed

    var body: some View {
        let displayImages = Array(images.prefix(4))
        let extraCount = images.count > 4 ? images.count - 4 : 0
        switch displayImages.count {
        case 1:
            singleImage(displayImages[0])
        case 2:
            twoImages(displayImages)
        case 3:
            threeImages(displayImages)
        case 4:
            fourImages(displayImages, extraCount: extraCount)
        default:
            EmptyView()
        }
    }

    // MARK: - Layouts
    private func singleImage(_ image: BSEmbedImage) -> some View {
        if let did = postAuthorDID, let cid = image.image?.ref?.link {
            return AnyView(
                BlueskyImageView(
                    pds: pds,
                    did: did,
                    cid: cid,
                    altText: image.alt ?? ""
                )
                .aspectRatio(16/9, contentMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 350)
                .clipped()
                .cornerRadius(0)
                .onTapGesture { selectedImageIndex = IdentifiableInt(id: 0) }
                .fullScreenCover(item: $selectedImageIndex) { identifiable in
                    fullScreenImage(for: identifiable.id)
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    private func twoImages(_ images: [BSEmbedImage]) -> some View {
        return AnyView(
            HStack(spacing: 4) {
                ForEach(0..<2, id: \ .self) { idx in
                    if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                        BlueskyImageView(
                            pds: pds,
                            did: did,
                            cid: cid,
                            altText: images[idx].alt ?? ""
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 220)
                        .clipped()
                        .onTapGesture { selectedImageIndex = IdentifiableInt(id: idx) }
                    } else {
                        EmptyView()
                    }
                }
            }
            .fullScreenCover(item: $selectedImageIndex) { identifiable in
                fullScreenImage(for: identifiable.id)
            }
        )
    }

    private func threeImages(_ images: [BSEmbedImage]) -> some View {
        if images.count < 3 {
            return AnyView(EmptyView())
        }
        return AnyView(
            GeometryReader { geo in
                HStack(spacing: 4) {
                    // Left: Tall image
                    if let did = postAuthorDID, let cid = images[0].image?.ref?.link {
                        BlueskyImageView(
                            pds: pds,
                            did: did,
                            cid: cid,
                            altText: images[0].alt ?? ""
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5 * 2 + 4)
                        .clipped()
                        .onTapGesture { selectedImageIndex = IdentifiableInt(id: 0) }
                    } else {
                        EmptyView()
                    }
                    VStack(spacing: 4) {
                        ForEach(1..<3, id: \ .self) { idx in
                            if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                                BlueskyImageView(
                                    pds: pds,
                                    did: did,
                                    cid: cid,
                                    altText: images[idx].alt ?? ""
                                )
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: geo.size.width * 0.5, height: (geo.size.width * 0.5 - 2))
                                .clipped()
                                .onTapGesture { selectedImageIndex = IdentifiableInt(id: idx) }
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
                .fullScreenCover(item: $selectedImageIndex) { identifiable in
                    fullScreenImage(for: identifiable.id)
                }
            }
            .frame(height: 2 * 110 + 4)
        )
    }

    private func fourImages(_ images: [BSEmbedImage], extraCount: Int) -> some View {
        return AnyView(
            {
                let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
                return LazyVGrid(columns: gridItems, spacing: 4) {
                    ForEach(0..<4, id: \ .self) { idx in
                        ZStack {
                            if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                                BlueskyImageView(
                                    pds: pds,
                                    did: did,
                                    cid: cid,
                                    altText: images[idx].alt ?? ""
                                )
                                .aspectRatio(1, contentMode: .fill)
                                .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 140)
                                .clipped()
                                .onTapGesture { selectedImageIndex = IdentifiableInt(id: idx) }
                            } else {
                                EmptyView()
                            }
                            if idx == 3 && extraCount > 0 {
                                Color.black.opacity(0.5)
                                Text("+\(extraCount)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .fullScreenCover(item: $selectedImageIndex) { identifiable in
                    fullScreenImage(for: identifiable.id)
                }
                .frame(height: 2 * 110 + 4)
            }()
        )
    }

    // Modal logic unchanged
    private func fullScreenImage(for index: Int) -> AnyView {
        if let did = postAuthorDID, let cid = images[index].image?.ref?.link {
            return AnyView(
                ZStack {
                    Color.black.ignoresSafeArea()
                    BlueskyImageView(
                        pds: pds,
                        did: did,
                        cid: cid,
                        altText: images[index].alt ?? ""
                    )
                    .onTapGesture { selectedImageIndex = nil }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

// MARK: - Zoomable Image View
private struct ZoomableImageView: View {
    let image: Image
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        scale = min(max(scale * delta, 1), 4)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if scale > 1 {
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        if scale > 1 {
                            lastOffset = offset
                        } else {
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
            )
    }
}

// MARK: - Gallery Image View
private struct GalleryImageView: View {
    let image: BSEmbedImage
    let index: Int
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    @Binding var retryCounts: [Int: Int]
    @Binding var useFullSize: [Int: Bool]
    
    private func getImageURL(from cid: String, isThumbnail: Bool = false) -> URL? {
        if let urlString = isThumbnail ? image.thumb : image.fullsize {
            return URL(string: urlString)
        }
        
        let baseUrl = isThumbnail ? "https://cdn.bsky.app/img/feed_thumbnail/plain/" : "https://cdn.bsky.app/img/feed_fullsize/plain/"
        if let cid = image.image?.ref?.link {
            let urlString = "\(baseUrl)\(cid)@jpeg"
            return URL(string: urlString)
        }
        return nil
    }
    
    var body: some View {
        if let cid = image.image?.ref?.link {
            let imageUrl = getImageURL(
                from: cid,
                isThumbnail: !(useFullSize[index] ?? false)
            )
            
            if let imageUrl = imageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        ZoomableImageView(
                            image: image,
                            scale: $scale,
                            lastScale: $lastScale,
                            offset: $offset,
                            lastOffset: $lastOffset
                        )
                        .onAppear {
                            if !(useFullSize[index] ?? false) && (retryCounts[index] ?? 0) == 0 {
                                useFullSize[index] = true
                            }
                        }
                    case .failure(let error):
                        if (retryCounts[index] ?? 0) < 2 {
                            EmptyView()
                                .onAppear {
                                    if !(useFullSize[index] ?? false) {
                                        useFullSize[index] = true
                                        retryCounts[index] = (retryCounts[index] ?? 0) + 1
                                    } else {
                                        useFullSize[index] = false
                                        retryCounts[index] = (retryCounts[index] ?? 0) + 1
                                    }
                                }
                        } else {
                            Image(systemName: "photo")
                                .foregroundStyle(.white)
                                .onAppear {
                                    print("DEBUG: Gallery image loading failed after retries - URL: \(imageUrl)")
                                    print("DEBUG: Error details: \(error.localizedDescription)")
                                }
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .tag(index)
            }
        }
    }
}

// MARK: - Image Gallery View
private struct ImageGalleryView: View {
    let images: [BSEmbedImage]
    let initialIndex: Int
    @Binding var isPresented: Bool
    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var retryCounts: [Int: Int] = [:]
    @State private var useFullSize: [Int: Bool] = [:]
    let sourceFrame: CGRect
    
    init(images: [BSEmbedImage], initialIndex: Int, isPresented: Binding<Bool>, sourceFrame: CGRect) {
        self.images = images
        self.initialIndex = initialIndex
        self._isPresented = isPresented
        self._currentIndex = State(initialValue: initialIndex)
        self.sourceFrame = sourceFrame
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.element.image?.ref?.link) { index, image in
                    GalleryImageView(
                        image: image,
                        index: index,
                        scale: $scale,
                        lastScale: $lastScale,
                        offset: $offset,
                        lastOffset: $lastOffset,
                        retryCounts: $retryCounts,
                        useFullSize: $useFullSize
                    )
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Actions Component
private struct PostActions: View {
    let post: FeedViewPost
    @Binding var isLiked: Bool
    @Binding var isReplied: Bool
    @Binding var isReposted: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ActionButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: post.post.likeCount,
                isActive: isLiked,
                color: .voxSecondary
            ) {
                isLiked.toggle()
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
                icon: isReposted ? "arrow.2.squarepath.fill" : "arrow.2.squarepath",
                count: post.post.repostCount,
                isActive: isReposted,
                color: .voxPrimary
            ) {
                isReposted.toggle()
            }
            
            Spacer(minLength: 0)
        }
        .frame(minHeight: 200)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Profile Image Component
private struct ProfileImage: View {
    let avatarURLString: String?
    
    var body: some View {
        if let avatarURLString = avatarURLString, let avatarURL = URL(string: avatarURLString) {
            AsyncImage(url: avatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFill()
                .foregroundStyle(.secondary)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
    }
}

// MARK: - Action Button Component
private struct ActionButton: View {
    let icon: String
    let count: Int
    let isActive: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isActive ? color : .secondary)
            }
            Text("\(count)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Environment Key for Post Author DID
private struct PostAuthorDIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var postAuthorDID: String? {
        get { self[PostAuthorDIDKey.self] }
        set { self[PostAuthorDIDKey.self] = newValue }
    }
}

// MARK: - Helper Identifiable wrapper for Int
private struct IdentifiableInt: Identifiable {
    let id: Int
}

// MARK: - Preview
#Preview("Text Only") {
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri",
            cid: "sample-cid",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Just finished reading 'The Midnight Library' by Matt Haig. What an incredible journey through infinite possibilities! The way it explores regret, choice, and the beauty of ordinary life really resonated with me. Highly recommend this thought-provoking read. #BookReview #TheMidnightLibrary",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 5,
            repostCount: 10,
            likeCount: 15,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: nil
        ),
        reply: nil,
        reason: nil,
        embed: nil,
        viewer: nil,
        labels: nil
    )
    
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Single Image") {
    let samplePost = FeedViewPost(
        post: BSPost(
            uri: "sample-uri",
            cid: "sample-cid",
            author: BSAuthor(
                did: "sample-did",
                handle: "sample.handle",
                displayName: "Sample User",
                avatar: nil,
                associated: nil,
                viewer: nil,
                labels: nil,
                createdAt: "2024-03-20T12:00:00Z"
            ),
            record: BSPostRecord(
                type: "app.bsky.feed.post",
                text: "Check out this beautiful sunset! 🌅",
                createdAt: "2024-03-20T12:00:00Z",
                embed: nil,
                reply: nil,
                langs: nil,
                facets: nil
            ),
            replyCount: 5,
            repostCount: 10,
            likeCount: 15,
            quoteCount: 0,
            indexedAt: "2024-03-20T12:00:00Z",
            viewer: nil,
            labels: nil,
            embed: nil
        ),
        reply: nil,
        reason: nil,
        embed: BSEmbed(
            type: "app.bsky.embed.images",
            record: nil,
            media: BSEmbedMedia(
                type: "app.bsky.embed.images",
                images: [
                    BSEmbedImage(
                        thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                        fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                        alt: "Beautiful sunset over the ocean",
                        aspectRatio: AspectRatio(height: 1023, width: 633),
                        image: nil
                    )
                ]
            ),
            images: [
                BSEmbedImage(
                    thumb: "https://cdn.bsky.app/img/feed_thumbnail/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                    fullsize: "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:zm75lxk5ul47zn6ycswxayja/bafkreiai2vkomzzmangxupgs7vd5ev2pivochtsnzisrgazpmcgk46utse@jpeg",
                    alt: "Beautiful sunset over the ocean",
                    aspectRatio: AspectRatio(height: 1023, width: 633),
                    image: nil
                )
            ],
            external: nil
        ),
        viewer: nil,
        labels: nil
    )
    
    ThreadView(post: samplePost)
        .padding()
        .previewLayout(.sizeThatFits)
}

// MARK: - Quoted Post View
private struct QuotedPostView: View {
    let quotedEmbed: BSEmbedRecordView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                if let avatar = quotedEmbed.post?.author.avatar, let url = URL(string: avatar) {
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
                Text("@" + (quotedEmbed.post?.author.formattedHandle ?? "unknown"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if let text = quotedEmbed.value?.text ?? quotedEmbed.post?.record.text {
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let images = quotedEmbed.embeds?.compactMap({ $0.images }).flatMap({ $0 }), !images.isEmpty {
                PostImages(images: images)
                    .environment(\.postAuthorDID, quotedEmbed.post?.author.did)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
} 
