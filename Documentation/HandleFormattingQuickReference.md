# Handle Formatting Quick Reference

## 🚀 Quick Start

### Basic Usage
```swift
// In your views
Text("@\(post.author.formattedHandle)")  // Smart formatting
Text("@\(post.author.compactHandle)")    // Compact display
Text("@\(post.author.profileHandle)")    // Profile display
```

### Direct Formatting
```swift
let formatted = HandleFormatter.shared.format("alice.bsky.social")
// Result: "alice"
```

## 🎯 Display Modes at a Glance

| Mode | Description | Example Input | Example Output |
|------|-------------|---------------|----------------|
| **Smart** (Default) | Intelligent filtering | `alice.bsky.social` | `alice` |
| | | `news.nytimes.com` | `news.nytimes.com` |
| **Hide Common** | Remove Bluesky domains only | `alice.bsky.social` | `alice` |
| | | `alice.com` | `alice.com` |
| **Hide All** | Remove all known TLDs | `alice.com` | `alice` |
| | | `news.nytimes.com` | `news.nytimes` |
| **Full** | Show complete handle | `alice.bsky.social` | `alice.bsky.social` |

## 🔧 Configuration

### User Settings Path
**Settings → Display → Handle Formatting**

### Programmatic Configuration
```swift
HandleFormatter.shared.updateConfiguration { config in
    config.defaultDisplayMode = .smart
    config.showDomainForVerifiedAccounts = true
}
```

## 📋 Common Patterns

### Always Hidden (Default)
- `.bsky.social`
- `.bsky.team`
- `.bsky.app`
- `.bsky.network`

### Optionally Hidden
- `.com`, `.org`, `.net`
- `.io`, `.dev`, `.app`
- `.social`, `.xyz`, `.me`
- Country codes: `.uk`, `.de`, `.jp`, etc.

## 🎨 UI Context Guidelines

| Context | Method | Behavior |
|---------|--------|----------|
| **Feed/Timeline** | `formattedHandle` | Smart mode, clean display |
| **Profile Page** | `profileHandle` | More complete info |
| **Notifications** | `compactHandle` | Aggressive filtering, truncation |
| **Search Results** | `formattedHandle` | Smart mode |
| **Settings/Admin** | `handle` (raw) | Full handle always |

## ✅ Best Practices

### DO ✓
- Use context-appropriate formatting methods
- Respect verified account status
- Test with various handle types
- Consider space constraints

### DON'T ✗
- Format handles in data/network layers
- Ignore user preferences
- Assume all handles have domains
- Hardcode formatting rules

## 🔍 Verification Detection

```swift
// Check if account has custom domain
if post.author.isVerified {
    // This account uses a custom domain
    // Handle will be preserved in smart mode
}
```

## 📊 Examples by Type

### Standard Users
```
alice.bsky.social    → @alice
bob.bsky.team       → @bob
```

### Organizations
```
news.nytimes.com    → @news.nytimes.com (preserved)
support.apple.com   → @support.apple.com (preserved)
```

### Edge Cases
```
verylongusername... → @verylongusern… (truncated)
user                → @user (no domain)
a.b.c.bsky.social  → @a.b.c
```

## 🛠 Troubleshooting

| Issue | Solution |
|-------|----------|
| Handle not formatting | Check if valid handle format |
| Custom domain hidden | Verify smart mode is active |
| Truncation too aggressive | Adjust maxLength parameter |
| Settings not persisting | Check @AppStorage keys |

## 📚 Related Documentation

- [Full Handle Formatting Documentation](./HandleFormatting.md)
- [AT Protocol Handle Specification](./BlueSkyHandleFormatting_NotionDoc.md)
- [Handle Resolution Diagrams](./HandleResolutionDiagram.md)
- [Implementation Summary](./HandleFormattingSummary.md) 