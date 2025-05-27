import SwiftUI

struct BlueskyImageView: View {
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
                    .cornerRadius(12)
                    .clipped()
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
} 
