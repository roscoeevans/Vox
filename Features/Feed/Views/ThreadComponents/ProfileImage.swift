import SwiftUI

struct ProfileImage: View {
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