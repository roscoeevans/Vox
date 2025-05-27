import SwiftUI

struct GalleryImageView: View {
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
