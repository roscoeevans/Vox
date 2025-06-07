import SwiftUI
import UIKit

// MARK: - Color Extensions
extension Color {
    // MARK: - Apple Intelligence-Inspired Primary Colors
    static let voxCoralRed = Color(hex: "FF3267")      // Warm accent
    static let voxGoldenYellow = Color(hex: "FCB025")  // Warm primary
    static let voxSkyBlue = Color(hex: "38BEFA")       // Cool primary
    
    // MARK: - Secondary Colors (Gradient Transitions)
    static let voxCoral = Color(hex: "F97B47")         // Bridges coral red to golden yellow
    static let voxBabyBlue = Color(hex: "A6D3E6")      // Bridges sky blue to golden yellow
    static let voxPeriwinkle = Color(hex: "CFA0FF")    // Bridges sky blue to coral red
    
    // MARK: - Background Colors
    static let voxBackground = Color(uiColor: .systemBackground)
    static let voxSecondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let voxTertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    
    // MARK: - Text Colors
    static let voxText = Color(uiColor: .label)
    static let voxSecondaryText = Color(uiColor: .secondaryLabel)
    static let voxTertiaryText = Color(uiColor: .tertiaryLabel)
    static let voxPlaceholderText = Color(uiColor: .placeholderText)
    
    // MARK: - Interactive Colors
    static let voxLink = voxSkyBlue
    static let voxSuccess = Color.green
    static let voxError = voxCoralRed
    static let voxWarning = voxGoldenYellow
    
    // MARK: - Separator Colors
    static let voxSeparator = Color(uiColor: .separator)
    static let voxOpaqueSeparator = Color(uiColor: .opaqueSeparator)
    
    // MARK: - Fill Colors
    static let voxFill = Color(uiColor: .systemFill)
    static let voxSecondaryFill = Color(uiColor: .secondarySystemFill)
    static let voxTertiaryFill = Color(uiColor: .tertiarySystemFill)
    static let voxQuaternaryFill = Color(uiColor: .quaternarySystemFill)
}

// MARK: - Gradient Definitions
extension LinearGradient {
    /// Warm gradient flowing from golden yellow through coral to coral red
    static let voxWarmGradient = LinearGradient(
        colors: [.voxGoldenYellow, .voxCoral, .voxCoralRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Cool gradient flowing from sky blue through baby blue to periwinkle
    static let voxCoolGradient = LinearGradient(
        colors: [.voxSkyBlue, .voxBabyBlue, .voxPeriwinkle],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )
    
    /// Full spectrum gradient incorporating all primary and secondary colors
    static let voxFullSpectrum = LinearGradient(
        colors: [.voxGoldenYellow, .voxCoral, .voxCoralRed, 
                 .voxPeriwinkle, .voxBabyBlue, .voxSkyBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Subtle gradient for backgrounds
    static let voxSubtleGradient = LinearGradient(
        colors: [.voxBabyBlue.opacity(0.1), .voxCoral.opacity(0.1)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Full screen gradient for login and splash screens
    static let voxFullScreenGradient = LinearGradient(
        colors: [
            .voxSkyBlue.opacity(0.8),
            .voxBabyBlue.opacity(0.6),
            .voxPeriwinkle.opacity(0.4),
            .voxCoral.opacity(0.3),
            .voxGoldenYellow.opacity(0.2)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Angular Gradient Definitions
extension AngularGradient {
    /// Ambient gradient for backgrounds with full color spectrum
    static let voxAmbient = AngularGradient(
        colors: [.voxGoldenYellow, .voxCoral, .voxCoralRed,
                 .voxPeriwinkle, .voxBabyBlue, .voxSkyBlue,
                 .voxGoldenYellow], // Loop back to start
        center: .center
    )
}

// MARK: - Radial Gradient Definitions
extension RadialGradient {
    /// Radial gradient for spotlight effects
    static let voxRadialWarm = RadialGradient(
        colors: [.voxGoldenYellow, .voxCoral, .voxCoralRed.opacity(0.3)],
        center: .center,
        startRadius: 5,
        endRadius: 100
    )
    
    /// Radial gradient for cool spotlight effects
    static let voxRadialCool = RadialGradient(
        colors: [.voxSkyBlue, .voxBabyBlue, .voxPeriwinkle.opacity(0.3)],
        center: .center,
        startRadius: 5,
        endRadius: 100
    )
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
