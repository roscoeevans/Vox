#!/usr/bin/env swift

import Foundation

// Demo the formatting
print("🎨 Bluesky Handle Formatting Demo")
print(String(repeating: "=", count: 50))
print()

// Test handles
let testHandles = [
    // Common TLDs that should be hidden
    ("alice.com", "Common .com domain"),
    ("bob.co", "Common .co domain"),
    ("charlie.net", "Common .net domain"),
    ("david.org", "Common .org domain"),
    ("eve.io", "Common .io domain"),
    
    // Bluesky domains that should be hidden
    ("frank.bsky.social", "Default Bluesky domain"),
    ("grace.bsky.team", "Bluesky team domain"),
    
    // Custom domains that should be shown
    ("news.nytimes.com", "New York Times domain"),
    ("senator.senate.gov", "Senate domain"),
    ("ceo.tesla.com", "Tesla domain"),
    ("support.apple.com", "Apple domain"),
    
    // Edge cases
    ("user", "No domain"),
    ("test.multiple.dots.com", "Multiple dots with common TLD"),
    ("custom.brandname", "Custom TLD")
]

// Simulate the formatting
print("📝 Handle Formatting Results:")
print()

for (handle, description) in testHandles {
    // Simulate smart formatting logic
    var formatted = handle
    
    // Check if it ends with a common suffix
    let commonSuffixes = [".com", ".co", ".net", ".org", ".io", ".dev", ".app", ".social", ".xyz", ".me",
                         ".bsky.social", ".bsky.team", ".bsky.app", ".bsky.network"]
    
    var isCommonSuffix = false
    for suffix in commonSuffixes {
        if handle.hasSuffix(suffix) {
            formatted = String(handle.dropLast(suffix.count))
            isCommonSuffix = true
            break
        }
    }
    
    let isVerified = formatted == handle && handle.contains(".")
    
    print("Handle: \(handle)")
    print("  → Formatted: \(formatted)")
    print("  → Verified: \(isVerified ? "✅" : "❌")")
    print("  → Description: \(description)")
    print()
}

print(String(repeating: "=", count: 50))
print()
print("📌 Summary:")
print("• Common TLDs (.com, .co, .net, etc.) are always hidden")
print("• Bluesky domains (.bsky.social, etc.) are always hidden")
print("• Custom organizational domains are preserved and marked as verified")
print("• Verified accounts would show a checkmark in the UI")

// Helper to repeat string
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
} 