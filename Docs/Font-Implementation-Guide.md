# Font Implementation Guide for Vox

## Overview
This guide explains how to change fonts throughout the Vox app, with a focus on navigation titles and maintaining a consistent typography system.

## Current Font System

The app now has a centralized typography system in `UI/Styles/Typography.swift` that makes it easy to switch between different font families.

## Available Font Options

### 1. **Free Google Fonts** (Recommended)

#### Montserrat
- **Style**: Geometric sans-serif, similar to Futura
- **Weights Available**: Thin to Black (100-900)
- **Best for**: Modern, clean look with geometric shapes
- **Download**: [Google Fonts - Montserrat](https://fonts.google.com/specimen/Montserrat)

#### Poppins
- **Style**: Geometric sans-serif with rounded edges
- **Weights Available**: Thin to Black (100-900)
- **Best for**: Friendly, approachable feel with modern roundness
- **Download**: [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)

#### DM Sans
- **Style**: Clean geometric sans-serif
- **Weights Available**: Regular to Bold (400-700)
- **Best for**: Minimal, professional look
- **Download**: [Google Fonts - DM Sans](https://fonts.google.com/specimen/DM+Sans)

### 2. **System Font (SF Pro)**
- Already included in iOS
- Native Apple feel
- Excellent readability
- Full Dynamic Type support

### 3. **Commercial Fonts** (Require License)
- ITC Avant Garde Gothic
- Futura

## How to Implement a Custom Font

### Step 1: Download Font Files

1. Visit the Google Fonts website for your chosen font
2. Download all weight variations you need:
   - Regular (400)
   - Medium (500)
   - SemiBold (600)
   - Bold (700)
   - ExtraBold (800)
   - Black (900)

### Step 2: Add Fonts to Xcode Project

1. Create a `Fonts` folder in `UI/Resources/`
2. Drag the `.ttf` or `.otf` files into Xcode
3. Make sure "Copy items if needed" is checked
4. Add to target: Vox

### Step 3: Update Info.plist

Add the following to your `Info.plist`:

```xml
<key>UIAppFonts</key>
<array>
    <string>Montserrat-Regular.ttf</string>
    <string>Montserrat-Medium.ttf</string>
    <string>Montserrat-SemiBold.ttf</string>
    <string>Montserrat-Bold.ttf</string>
    <string>Montserrat-ExtraBold.ttf</string>
    <string>Montserrat-Black.ttf</string>
</array>
```

### Step 4: Update Typography.swift

Change the font selection in `UI/Styles/Typography.swift`:

```swift
// Change this line to switch fonts app-wide
static let primaryFont: FontFamily = .montserrat  // or .poppins, .dmSans
```

### Step 5: Apply Navigation Title Font Modifier

Update your views to use the custom navigation title font:

```swift
NavigationStack {
    // Your content
}
.voxNavigationTitleFont()  // Add this modifier
```

## Implementation Examples

### For FeedView.swift:
```swift
NavigationStack {
    // ... existing content ...
}
.navigationTitle("Feed")
.voxNavigationTitleFont()  // Add this line
```

### For All Text in the App:
Replace standard font modifiers with the Vox typography system:

```swift
// Before:
Text("Hello").font(.title)

// After:
Text("Hello").font(.voxTitle())
```

## Font Weight Mapping

| UI Element | System Font | Custom Font Weight |
|------------|-------------|-------------------|
| Navigation Title (Large) | .largeTitle + .bold | ExtraBold (800) |
| Navigation Title (Small) | .headline | Bold (700) |
| Section Headers | .title2 | SemiBold (600) |
| Body Text | .body | Regular (400) |
| Usernames | .headline | SemiBold (600) |
| Timestamps | .caption | Regular (400) |

## Testing Your Font Implementation

1. **Check all navigation titles** - They should use the new font
2. **Verify Dynamic Type** - Text should scale with system settings
3. **Test on different devices** - Ensure readability on all screen sizes
4. **Check performance** - Custom fonts shouldn't impact scrolling

## Customizing the "VOX" Logo

For a more playful, customized look similar to the VOX media logo:

1. Create a custom `VoxLogoView` component
2. Use the extra bold weight of your chosen font
3. Apply custom letter spacing and curves
4. Consider using SF Symbols for decorative elements

Example:
```swift
struct VoxLogoView: View {
    var body: some View {
        Text("VOX")
            .font(.custom("Montserrat-ExtraBold", size: 40))
            .tracking(2)  // Letter spacing
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}
```

## Troubleshooting

### Font Not Showing
1. Check that font files are included in the app bundle
2. Verify Info.plist entries match exact filenames
3. Print available fonts: `UIFont.familyNames.forEach { print($0) }`

### Navigation Title Not Changing
1. Ensure `.voxNavigationTitleFont()` modifier is applied
2. Check that the modifier is after `.navigationTitle()`
3. Clean build folder and rebuild

### Performance Issues
1. Load fonts once at app startup
2. Use font caching
3. Avoid loading fonts in frequently called methods

## Next Steps

1. Choose your preferred font from the options above
2. Download and add the font files to the project
3. Update `Typography.swift` with your selection
4. Apply the navigation title modifier to all NavigationStack views
5. Test thoroughly on different devices and text sizes 