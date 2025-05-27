import SwiftUI

struct PostImages: View {
    let images: [BSEmbedImage]
    @State private var selectedImageIndex: IdentifiableInt? = nil
    @Environment(\.postAuthorDID) private var postAuthorDID
    let pds: String = "bsky.social"
    let spacing: CGFloat = 4
    let cornerRadius: CGFloat = 12

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
            let url = URL(string: image.fullsize ?? image.thumb ?? "") ?? blueskyBlobURL(pds: pds, did: did, cid: cid)
            let ar = image.aspectRatio
            let aspect: CGFloat = (ar.width > 0 && ar.height > 0) ? CGFloat(ar.width) / CGFloat(ar.height) : 16.0 / 9.0
            let isPortrait = aspect < 1
            let portraitAspect: CGFloat = 4.0 / 5.0 // Twitter's portrait crop
            return AnyView(
                GeometryReader { geo in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let img):
                            if isPortrait {
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(portraitAspect, contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.width / portraitAspect)
                                    .clipped()
                                    .clipShape(RoundedCorner(radius: cornerRadius, corners: .allCorners))
                                    .contentShape(Rectangle())
                            } else {
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(16/9, contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.width / (16.0/9.0))
                                    .clipped()
                                    .clipShape(RoundedCorner(radius: cornerRadius, corners: .allCorners))
                                    .contentShape(Rectangle())
                            }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 350)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .onTapGesture { selectedImageIndex = IdentifiableInt(id: 0) }
                    .fullScreenCover(item: $selectedImageIndex) { identifiable in
                        fullScreenImage(for: identifiable.id)
                    }
                }
                .frame(height: isPortrait ? UIScreen.main.bounds.width / portraitAspect : UIScreen.main.bounds.width / (16.0/9.0))
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    private func twoImages(_ images: [BSEmbedImage]) -> some View {
        GeometryReader { geo in
            HStack(spacing: spacing) {
                ForEach(0..<2, id: \.self) { idx in
                    if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                        BlueskyImageView(
                            pds: pds,
                            did: did,
                            cid: cid,
                            altText: images[idx].alt ?? ""
                        )
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: (geo.size.width - spacing) / 2, height: (geo.size.width - spacing) / 2)
                        .clipShape(RoundedCorner(radius: cornerRadius, corners: idx == 0 ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight]))
                        .contentShape(Rectangle())
                        .onTapGesture { selectedImageIndex = IdentifiableInt(id: idx) }
                    } else {
                        EmptyView()
                    }
                }
            }
            .fullScreenCover(item: $selectedImageIndex) { identifiable in
                fullScreenImage(for: identifiable.id)
            }
        }
        .frame(height: 200)
    }

    private func threeImages(_ images: [BSEmbedImage]) -> some View {
        GeometryReader { geo in
            let side = (geo.size.width - spacing) / 2
            HStack(spacing: spacing) {
                // Left: Tall image
                if let did = postAuthorDID, let cid = images[0].image?.ref?.link {
                    BlueskyImageView(
                        pds: pds,
                        did: did,
                        cid: cid,
                        altText: images[0].alt ?? ""
                    )
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: side, height: side * 2 + spacing)
                    .clipShape(RoundedCorner(radius: cornerRadius, corners: [.topLeft, .bottomLeft]))
                    .contentShape(Rectangle())
                    .onTapGesture { selectedImageIndex = IdentifiableInt(id: 0) }
                }
                VStack(spacing: spacing) {
                    ForEach(1..<3, id: \.self) { idx in
                        if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                            BlueskyImageView(
                                pds: pds,
                                did: did,
                                cid: cid,
                                altText: images[idx].alt ?? ""
                            )
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: side, height: side)
                            .clipShape(RoundedCorner(radius: cornerRadius, corners: idx == 1 ? [.topRight] : [.bottomRight]))
                            .contentShape(Rectangle())
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
        .frame(height: 200)
    }

    private func fourImages(_ images: [BSEmbedImage], extraCount: Int) -> some View {
        let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: gridItems, spacing: spacing) {
            ForEach(0..<4, id: \.self) { idx in
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
                        .clipShape(RoundedCorner(radius: cornerRadius, corners: fourImageCorners(for: idx)))
                        .contentShape(Rectangle())
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
        .frame(height: 200)
    }

    private func fourImageCorners(for idx: Int) -> UIRectCorner {
        switch idx {
        case 0: return [.topLeft]
        case 1: return [.topRight]
        case 2: return [.bottomLeft]
        case 3: return [.bottomRight]
        default: return []
        }
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
