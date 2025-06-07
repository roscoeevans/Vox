# Bluesky Handle Formatting: Protocol & Implementation

## Table of Contents
1. [Overview](#overview)
2. [AT Protocol Handle System](#at-protocol-handle-system)
3. [Domain Verification Methods](#domain-verification-methods)
4. [Handle Resolution Workflow](#handle-resolution-workflow)
5. [Our Handle Formatting Implementation](#our-handle-formatting-implementation)
6. [Display Modes & Configuration](#display-modes--configuration)
7. [Technical Architecture](#technical-architecture)
8. [Best Practices](#best-practices)

---

## Overview

This document covers two interconnected aspects of Bluesky handles:
1. **The AT Protocol specification** for how handles work with domain names
2. **Our implementation** for intelligently formatting handles in the Vox app UI

### Key Concepts
- **DID (Decentralized Identifier)**: A permanent, immutable identifier (e.g., `did:plc:xyz...`)
- **Handle**: A human-friendly, DNS-like username (e.g., `alice.bsky.social`)
- **Domain Verification**: Proving ownership of a domain to use it as a handle
- **Handle Formatting**: Our system for displaying handles cleanly in the UI

---

## AT Protocol Handle System

### Identity Model
Bluesky's identity model separates:
- **DIDs**: Long-term, immutable identifiers
- **Handles**: Mutable, DNS-like names used as visible usernames

### Handle Requirements
Handles must be valid Internet hostnames:
- ASCII letters, digits, or hyphens
- Split by periods
- At least two segments (no bare TLDs)
- Examples: `atproto.bsky.social`, `atproto.com`, `npr.org`

### Bidirectional Binding
The protocol requires a bidirectional binding between handle and DID:
1. Handle → DID: Resolve handle to find the DID
2. DID → Handle: DID Document must reference the handle

---

## Domain Verification Methods

### Method 1: DNS TXT Record
Place the account's DID in a TXT record under `_atproto` subdomain:

```
Domain: example.com
DNS Record: _atproto.example.com
Type: TXT
Value: did=did:plc:XXXX
```

**Example**: Handle `bsky.app` requires DNS TXT at `_atproto.bsky.app` containing `did=did:plc:z72i7hdynmk6r22z27h6tvur`

### Method 2: HTTPS Well-Known Endpoint
Serve the DID over HTTPS at a specific path:

```
URL: https://<handle>/.well-known/atproto-did
Method: GET
Response: 200 OK
Content-Type: text/plain
Body: did:plc:abcdef...
```

**Example**: `https://bsky.app/.well-known/atproto-did` returns the raw DID string

### Advantages
- **DNS Method**: Simple for single handles
- **HTTPS Method**: Better for organizations with many subdomains

---

## Handle Resolution Workflow

### Step 1: Retrieve DID from Handle
1. Try DNS TXT lookup at `_atproto.<handle>`
2. Or fetch `https://<handle>/.well-known/atproto-did`
3. Extract the DID (e.g., `did:plc:12345...`)

### Step 2: Fetch DID Document
1. Query the appropriate DID registry
2. For `did:plc`: Query Bluesky's PLC directory
3. For `did:web`: Retrieve JSON from domain
4. Verify the document contains `alsoKnownAs` field with the handle

### Validation
Handle is only valid if:
- Domain proves the DID (via DNS/HTTPS)
- DID Document proves the handle (via `alsoKnownAs`)

---

## Our Handle Formatting Implementation

### Problem Statement
Bluesky handles often include redundant domain suffixes that create visual clutter:
- `alice.bsky.social` → Could display as `@alice`
- `news.nytimes.com` → Should remain `@news.nytimes.com` for recognition

### Solution: Intelligent Handle Formatting
We've built a configurable system that:
1. Removes common Bluesky domains (`.bsky.social`, `.bsky.team`, etc.)
2. Preserves custom domains for verified accounts
3. Adapts to different UI contexts
4. Respects user preferences

### Core Components

#### HandleFormatter (Singleton)
```swift
HandleFormatter.shared.format("alice.bsky.social")
// Returns: "alice"

HandleFormatter.shared.format("news.nytimes.com", mode: .smart)
// Returns: "news.nytimes.com" (preserved)
```

#### BSAuthor Model Extensions
```swift
post.author.formattedHandle  // Smart formatting for feeds
post.author.compactHandle    // Space-constrained display
post.author.profileHandle    // Profile page display
post.author.isVerified       // Domain-based verification
```

---

## Display Modes & Configuration

### Available Display Modes

#### 1. Smart Mode (Default)
- Hides common Bluesky suffixes
- Preserves custom domains
- Respects verified account settings
- Best for most use cases

#### 2. Hide Common Suffixes
- Only removes Bluesky-specific domains
- Preserves all other domains
- Good for clarity without being aggressive

#### 3. Hide All Known Suffixes
- Removes all recognized TLDs
- Maximum space saving
- Best for compact views

#### 4. Full Display
- Shows complete handles
- No modifications
- Best for technical users

### Configuration Options

#### Always Hidden Suffixes
```swift
.bsky.social
.bsky.team
.bsky.app
.bsky.network
```

#### Optionally Hidden Suffixes
```swift
.com, .org, .net, .io, .dev, .app, .social, 
.xyz, .me, .co, .us, .uk, .ca, .au, .de, 
.fr, .jp, .cn, .in, .br
```

### User Settings
Users can configure via Settings → Display → Handle Formatting:
- Display mode selection
- Verified account handling
- Common domain filtering
- Live preview with test handles

---

## Technical Architecture

### Performance Characteristics
- **Lookup**: O(1) using Set collections
- **Memory**: Minimal with shared singleton
- **Thread Safety**: Read-only operations are thread-safe
- **Persistence**: UserDefaults via @AppStorage

### String Extensions
```swift
// Validation
"alice.bsky.social".isValidHandle // true

// Component extraction
"alice.bsky.social".handleUsername // "alice"
"alice.bsky.social".handleDomain   // ".bsky.social"

// Formatting
handle.formatHandle(using: .compact)
handle.formatHandle(using: .standard)
```

### Context-Aware Formatting
Different contexts use different formatting:
- **Feed View**: `formatForFeed()` - Smart mode
- **Profile View**: `formatForProfile()` - Show more info
- **Compact View**: `formatCompact()` - Aggressive filtering

---

## Best Practices

### For Developers

1. **Use Appropriate Context Methods**
   ```swift
   // In feed views
   Text("@\(post.author.formattedHandle)")
   
   // In space-constrained areas
   Text("@\(post.author.compactHandle)")
   
   // On profile pages
   Text("@\(user.profileHandle)")
   ```

2. **Respect Verification Status**
   - Always show full handles for verified accounts
   - Use `isVerified` property to detect custom domains

3. **Handle Edge Cases**
   - Empty handles
   - Handles without domains
   - International domains
   - Very long handles

### For Users

1. **Choose the Right Display Mode**
   - Smart mode for balanced display
   - Full mode for seeing everything
   - Compact modes for cleaner UI

2. **Custom Domain Considerations**
   - Custom domains indicate verified/notable accounts
   - They're preserved in smart mode
   - Can be hidden in aggressive modes

3. **Testing Handles**
   - Use the settings preview
   - Test with various handle types
   - Verify your preferences work as expected

---

## Examples

### Standard Formatting
| Handle | Smart Mode | Hide Common | Hide All | Compact |
|--------|------------|-------------|----------|---------|
| alice.bsky.social | @alice | @alice | @alice | @alice |
| news.nytimes.com | @news.nytimes.com | @news.nytimes.com | @news.nytimes | @news.nytimes |
| user.custom.app | @user.custom.app | @user.custom.app | @user.custom | @user.custom |
| verylongusername.bsky.social | @verylongusername | @verylongusername | @verylongusername | @verylongusern… |

### Domain Verification in Action
1. User claims handle `alice.example.com`
2. Sets DNS TXT: `_atproto.alice.example.com` → `did=did:plc:abc123`
3. Bluesky verifies the record
4. Our formatter shows as `@alice.example.com` (custom domain preserved)

---

## Integration with AT Protocol

### How Our Formatting Respects the Protocol

1. **Preserves Identity**
   - Formatting is display-only
   - Underlying handle remains unchanged
   - DID resolution still works

2. **Highlights Verification**
   - Custom domains indicate domain control
   - Matches protocol's verification model
   - Builds user trust

3. **Enhances Usability**
   - Makes handles more readable
   - Reduces cognitive load
   - Maintains protocol compliance

### Future Considerations

1. **Protocol Evolution**
   - New domain verification methods
   - Additional DID methods beyond plc/web
   - Enhanced verification signals

2. **UI Enhancements**
   - Verification badges
   - Domain reputation scoring
   - Animated transitions

3. **Accessibility**
   - Screen reader considerations
   - High contrast modes
   - Internationalization

---

## Summary

The Bluesky AT Protocol provides a robust system for using domain names as handles through DNS/HTTPS verification. Our handle formatting implementation builds on this foundation to create a cleaner, more readable UI while respecting the protocol's identity model.

Key takeaways:
- Domain handles prove ownership through DNS TXT or HTTPS endpoints
- Handle resolution involves bidirectional verification
- Our formatter intelligently removes redundant suffixes
- Users have full control over display preferences
- The system respects verified accounts and custom domains

This combination of protocol compliance and thoughtful UI design creates a better user experience while maintaining the decentralized nature of Bluesky's identity system. 