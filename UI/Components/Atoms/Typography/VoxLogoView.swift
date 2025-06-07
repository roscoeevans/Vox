import SwiftUI

struct VoxLogoView: View {
    var size: CGFloat = 40
    var useGradient: Bool = true
    
    var body: some View {
        if useGradient {
            Text("VOX")
                .font(logoFont)
                .tracking(size * 0.05)  // Dynamic letter spacing based on size
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.blue,
                            Color.purple.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Add subtle shadow for depth
                    Text("VOX")
                        .font(logoFont)
                        .tracking(size * 0.05)
                        .foregroundStyle(.black.opacity(0.1))
                        .offset(x: 1, y: 1)
                        .blur(radius: 1)
                )
        } else {
            Text("VOX")
                .font(logoFont)
                .tracking(size * 0.05)  // Dynamic letter spacing based on size
                .foregroundStyle(Color.primary)
                .overlay(
                    // Add subtle shadow for depth
                    Text("VOX")
                        .font(logoFont)
                        .tracking(size * 0.05)
                        .foregroundStyle(.black.opacity(0.1))
                        .offset(x: 1, y: 1)
                        .blur(radius: 1)
                )
        }
    }
    
    private var logoFont: Font {
        switch Typography.primaryFont {
        case .system:
            return .system(size: size, weight: .black, design: .rounded)
        default:
            return .custom(
                Typography.FontWeight.black.customFontName(for: Typography.primaryFont),
                size: size
            )
        }
    }
}

// MARK: - Custom Letter View for More Control
struct VoxCustomLogoView: View {
    var size: CGFloat = 40
    
    var body: some View {
        HStack(spacing: -size * 0.05) {  // Negative spacing for tighter letters
            // V with exaggerated curves
            Text("V")
                .font(letterFont)
                .rotationEffect(.degrees(-2))
                .offset(y: -2)
            
            // O with perfect circle
            Text("O")
                .font(letterFont)
                .scaleEffect(1.1)
            
            // X with playful tilt
            Text("X")
                .font(letterFont)
                .rotationEffect(.degrees(2))
                .offset(y: -2)
        }
        .foregroundStyle(
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 1.0),
                    Color(red: 0.6, green: 0.2, blue: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    private var letterFont: Font {
        switch Typography.primaryFont {
        case .system:
            return .system(size: size, weight: .black, design: .rounded)
        default:
            return .custom(
                Typography.FontWeight.black.customFontName(for: Typography.primaryFont),
                size: size
            )
        }
    }
}

#Preview("Logo Variations") {
    VStack(spacing: 30) {
        VoxLogoView(size: 60)
        
        VoxLogoView(size: 40, useGradient: false)
        
        VoxCustomLogoView(size: 50)
        
        // Example in navigation bar
        HStack {
            VoxLogoView(size: 28)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    .padding()
} 