# Handle Formatting System

## Overview

The Vox app includes a robust handle formatting system that intelligently filters domain names from Bluesky handles to improve readability and reduce visual clutter. This system is highly configurable and context-aware.

## Features

### 1. **Smart Domain Filtering**
- Automatically removes common Bluesky domains (`.bsky.social`, `.bsky.team`, etc.)
- Optionally filters well-known TLDs (`.com`, `.org`, `.net`, etc.)
- Preserves custom domains for verified accounts and organizations
- Handles international domains correctly

### 2. **Multiple Display Modes**
- **Smart Mode** (Default): Intelligently decides when to show/hide domains
- **Hide Common Suffixes**: Only removes Bluesky-specific domains
- **Hide All Known Suffixes**: Removes all recognized TLDs
- **Full Display**: Always shows complete handles
- **Custom Mode**: Apply custom formatting logic

### 3. **Context-Aware Formatting**
- Different formatting for feed, profile, and compact views
- Respects verified account status
- Handles truncation gracefully with ellipsis

### 4. **User Preferences**
- Configurable through Settings UI
- Persistent preferences using `@AppStorage`
- Live preview of formatting changes

## Usage

### Basic Usage

```swift
// Using the default formatter
let formatted = HandleFormatter.shared.format("alice.bsky.social")
// Result: "alice"

// Using specific display modes
let full = HandleFormatter.shared.format(handle, mode: .full)
let compact = HandleFormatter.shared.formatCompact(handle)
let feedFormat = HandleFormatter.shared.formatForFeed(handle, isVerified: true)
```

### In SwiftUI Views

```swift
// In a post view
Text("@\(post.author.formattedHandle)")

// For compact display
Text("@\(post.author.compactHandle)")

// For profile display
Text("@\(post.author.profileHandle)")
```

### Configuration

```swift
// Update formatter configuration
HandleFormatter.shared.updateConfiguration { config in
    config.defaultDisplayMode = .smart
    config.showDomainForVerifiedAccounts = true
    config.alwaysHiddenSuffixes.insert(".custom.domain")
    config.neverHiddenDomains.insert(".important.com")
}
```

## String Extensions

The system includes helpful String extensions for handle manipulation:

```swift
// Check if string is a valid handle
"alice.bsky.social".isValidHandle // true

// Extract components
"alice.bsky.social".handleUsername // "alice"
"alice.bsky.social".handleDomain // ".bsky.social"

// Use display configurations
handle.formatHandle(using: .compact)
handle.formatHandle(using: .standard)
handle.formatHandle(using: .full)
```

## Display Mode Details

### Smart Mode
The default mode that makes intelligent decisions:
- Hides common Bluesky suffixes
- Shows custom domains
- Respects verified account settings
- Shows domains that might be important for context

### Hide Common Suffixes
Only removes known Bluesky-related domains:
- `.bsky.social`
- `.bsky.team`
- `.bsky.app`
- `.bsky.network`

### Hide All Known Suffixes
Aggressively removes all recognized TLDs:
- All common suffixes
- Well-known TLDs (`.com`, `.org`, `.net`, etc.)
- International domains (`.uk`, `.jp`, `.de`, etc.)

### Full Display
Never modifies handles - always shows the complete handle as-is.

## Settings UI

Users can customize handle display through the Settings screen:

1. **Display Mode Selection**: Choose between Smart, Hide Common, Hide All, or Full
2. **Verified Account Handling**: Toggle whether to show domains for verified accounts
3. **Common Domain Filtering**: Toggle filtering of well-known TLDs
4. **Live Preview**: See how different handles will appear with current settings
5. **Custom Handle Testing**: Enter any handle to see how it will be formatted

## Best Practices

1. **Use Smart Mode by Default**: It provides the best balance between clarity and information
2. **Respect Context**: Use `formatForFeed()` in timelines, `formatForProfile()` on profile pages
3. **Consider Truncation**: Use `formatCompact()` or specify `maxLength` for space-constrained UI
4. **Test Edge Cases**: Always test with various handle formats including international domains

## Examples

```swift
// Standard Bluesky handle
"alice.bsky.social" → "alice"

// Custom domain (preserved in smart mode)
"news.nytimes.com" → "news.nytimes.com"

// Organization handle
"support.apple.com" → "support.apple.com"

// International domain
"user.co.jp" → "user.co.jp" (smart mode)
"user.co.jp" → "user.co" (hide all mode)

// Long handle with truncation
"verylongusername.bsky.social" → "verylongu…" (maxLength: 10)
```

## Testing

The system includes comprehensive unit tests covering:
- Basic formatting scenarios
- Smart mode logic
- Truncation behavior
- Configuration changes
- Edge cases and international domains
- Batch processing

Run tests with:
```bash
swift test --filter HandleFormatterTests
```

## Future Enhancements

Potential improvements for future versions:
1. Domain reputation scoring
2. ML-based importance detection
3. Per-user formatting preferences
4. Handle verification badges
5. Animated transitions between formats
6. Accessibility considerations for screen readers 