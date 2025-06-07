import SwiftUI

// MARK: - Typography System
struct Typography {
    // MARK: - Font Configuration
    enum FontFamily {
        case system // SF Pro
        case montserrat
        case poppins
        case dmSans
        case custom(String)
        
        var name: String {
            switch self {
            case .system:
                return ".SF Pro Display"
            case .montserrat:
                return "Montserrat"
            case .poppins:
                return "Poppins"
            case .dmSans:
                return "DMSans"
            case .custom(let name):
                return name
            }
        }
    }
    
    // MARK: - Current Font Selection
    // Change this to switch fonts app-wide
    static let primaryFont: FontFamily = .system
    
    // MARK: - Font Weights
    enum FontWeight {
        case regular
        case medium
        case semibold
        case bold
        case extraBold
        case black
        
        var systemWeight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            case .extraBold: return .heavy
            case .black: return .black
            }
        }
        
        func customFontName(for family: FontFamily) -> String {
            let base = family.name
            switch self {
            case .regular:
                return base + "-Regular"
            case .medium:
                return base + "-Medium"
            case .semibold:
                return base + "-SemiBold"
            case .bold:
                return base + "-Bold"
            case .extraBold:
                return base + "-ExtraBold"
            case .black:
                return base + "-Black"
            }
        }
    }
}

// MARK: - Font Extensions
extension Font {
    // MARK: - Navigation Title Font
    static func voxNavigationTitle() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .largeTitle.weight(.bold)
        default:
            return .custom(
                Typography.FontWeight.extraBold.customFontName(for: Typography.primaryFont),
                size: 34
            )
        }
    }
    
    // MARK: - Text Styles
    static func voxTitle() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .title.weight(.bold)
        default:
            return .custom(
                Typography.FontWeight.bold.customFontName(for: Typography.primaryFont),
                size: 28
            )
        }
    }
    
    static func voxTitle2() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .title2.weight(.semibold)
        default:
            return .custom(
                Typography.FontWeight.semibold.customFontName(for: Typography.primaryFont),
                size: 22
            )
        }
    }
    
    static func voxHeadline() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .headline
        default:
            return .custom(
                Typography.FontWeight.semibold.customFontName(for: Typography.primaryFont),
                size: 17
            )
        }
    }
    
    static func voxBody() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .body
        default:
            return .custom(
                Typography.FontWeight.regular.customFontName(for: Typography.primaryFont),
                size: 17
            )
        }
    }
    
    static func voxCallout() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .callout
        default:
            return .custom(
                Typography.FontWeight.regular.customFontName(for: Typography.primaryFont),
                size: 16
            )
        }
    }
    
    static func voxSubheadline() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .subheadline
        default:
            return .custom(
                Typography.FontWeight.regular.customFontName(for: Typography.primaryFont),
                size: 15
            )
        }
    }
    
    static func voxFootnote() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .footnote
        default:
            return .custom(
                Typography.FontWeight.regular.customFontName(for: Typography.primaryFont),
                size: 13
            )
        }
    }
    
    static func voxCaption() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .caption
        default:
            return .custom(
                Typography.FontWeight.regular.customFontName(for: Typography.primaryFont),
                size: 12
            )
        }
    }
    
    static func voxCaption2() -> Font {
        switch Typography.primaryFont {
        case .system:
            return .caption2
        default:
            return .custom(
                Typography.FontWeight.regular.customFontName(for: Typography.primaryFont),
                size: 11
            )
        }
    }
}

// MARK: - View Modifier for Navigation Title Font
struct NavigationTitleFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Customize navigation bar appearance
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                
                // Only customize fonts for non-system fonts
                switch Typography.primaryFont {
                case .system:
                    // Use default system fonts
                    break
                default:
                    // Large title font
                    appearance.largeTitleTextAttributes = [
                        .font: UIFont(name: Typography.FontWeight.extraBold.customFontName(for: Typography.primaryFont), size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)
                    ]
                    
                    // Standard title font
                    appearance.titleTextAttributes = [
                        .font: UIFont(name: Typography.FontWeight.bold.customFontName(for: Typography.primaryFont), size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
                    ]
                }
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}

extension View {
    func voxNavigationTitleFont() -> some View {
        self.modifier(NavigationTitleFontModifier())
    }
}

// MARK: - Font Registration Helper
struct FontRegistration {
    static func registerCustomFonts() {
        // Register Montserrat fonts
        let fontNames = [
            "Montserrat-Regular",
            "Montserrat-Medium",
            "Montserrat-SemiBold",
            "Montserrat-Bold",
            "Montserrat-ExtraBold",
            "Montserrat-Black"
        ]
        
        for fontName in fontNames {
            registerFont(bundle: .main, fontName: fontName, fontExtension: "ttf")
        }
    }
    
    private static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            print("Failed to register font: \(fontName)")
            return
        }
        
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
        
        if let error = error {
            print("Error registering font \(fontName): \(error.takeUnretainedValue())")
        } else {
            print("Successfully registered font: \(fontName)")
        }
    }
} 