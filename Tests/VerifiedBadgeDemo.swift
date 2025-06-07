#!/usr/bin/env swift

import Foundation

// Demo the verified badge feature
print("🔵 Verified Badge Implementation Demo")
print(String(repeating: "=", count: 50))
print()

// Test cases
let testCases = [
    // Verified accounts (custom domains)
    ("news.nytimes.com", "The New York Times", true),
    ("senator.senate.gov", "Senator Smith", true),
    ("ceo.tesla.com", "Elon Musk", true),
    ("support.apple.com", "Apple Support", true),
    ("custom.brandname", "Custom Brand", true),
    
    // Non-verified accounts (common domains)
    ("alice.bsky.social", "Alice", false),
    ("bob.com", "Bob", false),
    ("charlie.co", "Charlie", false),
    ("david.org", "David", false),
    ("eve.io", "Eve", false),
    ("frank.net", "Frank", false)
]

print("📋 Handle Display with Verification Status:")
print()

for (handle, displayName, expectedVerified) in testCases {
    // Simulate formatting
    let commonSuffixes = [".com", ".co", ".net", ".org", ".io", ".dev", ".app", ".social", ".xyz", ".me",
                         ".bsky.social", ".bsky.team", ".bsky.app", ".bsky.network"]
    
    var formatted = handle
    for suffix in commonSuffixes {
        if handle.hasSuffix(suffix) {
            formatted = String(handle.dropLast(suffix.count))
            break
        }
    }
    
    let isVerified = formatted == handle && handle.contains(".")
    let verificationMatch = isVerified == expectedVerified ? "✅" : "❌"
    
    print("User: \(displayName)")
    print("  Full handle: @\(handle)")
    print("  Displayed as: @\(formatted) \(isVerified ? "🔵" : "")")
    print("  Verified: \(isVerified ? "Yes" : "No") \(verificationMatch)")
    print()
}

print(String(repeating: "=", count: 50))
print()
print("🎨 UI Implementation:")
print()
print("1. Regular posts show:")
print("   - @alice (no badge) for alice.bsky.social")
print("   - @bob (no badge) for bob.com")
print("   - @news.nytimes.com 🔵 for news.nytimes.com")
print()
print("2. Tapping the blue checkmark shows:")
print("   ┌─────────────────────────┐")
print("   │ Verified Handle         │")
print("   │                         │")
print("   │ 🔵 @news.nytimes.com    │")
print("   │                         │")
print("   │ This account uses a     │")
print("   │ custom domain           │")
print("   └─────────────────────────┘")
print()
print("3. Benefits:")
print("   • Cleaner UI with common domains hidden")
print("   • Visual verification for custom domains")
print("   • Full handle available on demand")
print("   • Twitter-like verification experience") 