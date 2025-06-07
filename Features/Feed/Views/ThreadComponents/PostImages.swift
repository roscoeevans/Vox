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
                    let imageHeight = isPortrait ? geo.size.width / portraitAspect : geo.size.width / (16.0/9.0)
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: geo.size.width, height: imageHeight)
                        case .success(let img):
                            if isPortrait {
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(portraitAspect, contentMode: .fill)
                                    .frame(width: geo.size.width, height: imageHeight)
                                    .clipped()
                                    .clipShape(SelectiveRoundedCorners(corners: .allCorners, radius: cornerRadius))
                                    .contentShape(Rectangle())
                            } else {
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(16/9, contentMode: .fill)
                                    .frame(width: geo.size.width, height: imageHeight)
                                    .clipped()
                                    .clipShape(SelectiveRoundedCorners(corners: .allCorners, radius: cornerRadius))
                                    .contentShape(Rectangle())
                            }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width, height: imageHeight)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .onTapGesture { selectedImageIndex = IdentifiableInt(id: 0) }
                    .fullScreenCover(item: $selectedImageIndex) { identifiable in
                        fullScreenImage(for: identifiable.id)
                    }
                }
                .aspectRatio(isPortrait ? portraitAspect : 16.0/9.0, contentMode: .fit)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    private func twoImages(_ images: [BSEmbedImage]) -> some View {
        GeometryReader { geo in
            let imageSize = (geo.size.width - spacing) / 2
            let aspect: CGFloat = 8.0 / 9.0 // Twitter-style aspect ratio for two images
            let imageHeight = imageSize / aspect
            
            HStack(spacing: spacing) {
                ForEach(0..<2) { idx in
                    if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                        BlueskyImageView(
                            pds: pds,
                            did: did,
                            cid: cid,
                            altText: images[idx].alt ?? ""
                        )
                        .aspectRatio(aspect, contentMode: .fill)
                        .frame(width: imageSize, height: imageHeight)
                        .clipShape(SelectiveRoundedCorners(corners: idx == 0 ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight], radius: cornerRadius))
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
        .aspectRatio(CGFloat(2 * 8) / 9, contentMode: .fit) // Total aspect ratio for two 8:9 images side by side
    }

    private func threeImages(_ images: [BSEmbedImage]) -> some View {
        GeometryReader { geo in
            let side = (geo.size.width - spacing) / 2
            let leftAspect: CGFloat = 8.0 / 9.0
            let rightAspect: CGFloat = 16.0 / 9.0
            let leftHeight = side / leftAspect
            let rightHeight = side / rightAspect
            
            HStack(spacing: spacing) {
                // Left: Tall image with 8:9 aspect ratio
                if let did = postAuthorDID, let cid = images[0].image?.ref?.link {
                    BlueskyImageView(
                        pds: pds,
                        did: did,
                        cid: cid,
                        altText: images[0].alt ?? ""
                    )
                    .aspectRatio(leftAspect, contentMode: .fill)
                    .frame(width: side, height: leftHeight)
                    .clipShape(SelectiveRoundedCorners(corners: [.topLeft, .bottomLeft], radius: cornerRadius))
                    .contentShape(Rectangle())
                    .onTapGesture { selectedImageIndex = IdentifiableInt(id: 0) }
                }
                VStack(spacing: spacing) {
                    ForEach(1..<3) { idx in
                        if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                            BlueskyImageView(
                                pds: pds,
                                did: did,
                                cid: cid,
                                altText: images[idx].alt ?? ""
                            )
                            .aspectRatio(rightAspect, contentMode: .fill)
                            .frame(width: side, height: rightHeight)
                            .clipShape(SelectiveRoundedCorners(corners: idx == 1 ? [.topRight] : [.bottomRight], radius: cornerRadius))
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
        .aspectRatio(CGFloat(2 * 8) / 9, contentMode: .fit) // Match the left image height
    }

    private func fourImages(_ images: [BSEmbedImage], extraCount: Int) -> some View {
        let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
        let aspectRatio: CGFloat = 16.0 / 9.0
        
        return GeometryReader { geo in
            let imageWidth = (geo.size.width - spacing) / 2
            let imageHeight = imageWidth / aspectRatio
            
            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(0..<4) { idx in
                    ZStack {
                        if let did = postAuthorDID, let cid = images[idx].image?.ref?.link {
                            BlueskyImageView(
                                pds: pds,
                                did: did,
                                cid: cid,
                                altText: images[idx].alt ?? ""
                            )
                            .aspectRatio(aspectRatio, contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .clipShape(SelectiveRoundedCorners(corners: fourImageCorners(for: idx), radius: cornerRadius))
                            .contentShape(Rectangle())
                            .onTapGesture { selectedImageIndex = IdentifiableInt(id: idx) }
                        } else {
                            EmptyView()
                        }
                        if idx == 3 && extraCount > 0 {
                            Color.black.opacity(0.5)
                                .clipShape(SelectiveRoundedCorners(corners: [.bottomRight], radius: cornerRadius))
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
        }
        .aspectRatio(aspectRatio, contentMode: .fit) // Grid has same aspect ratio as individual images
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
