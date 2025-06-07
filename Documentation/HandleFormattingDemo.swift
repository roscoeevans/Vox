#!/usr/bin/env swift

// Handle Formatting Demo
// This script demonstrates the various handle formatting capabilities

import Foundation

// Simplified HandleFormatter for demo purposes
class HandleFormatter {
    static let shared = HandleFormatter()
    
    private let commonSuffixes = [".bsky.social", ".bsky.team", ".bsky.app", ".bsky.network"]
    private let wellKnownTLDs = [".com", ".org", ".net", ".io", ".dev", ".social"]
    
    func formatDemo() {
        print("🎨 Bluesky Handle Formatting Demo\n")
        print("=" * 60)
        
        // Demo handles
        let demoHandles = [
            ("alice.bsky.social", "Standard Bluesky user"),
            ("bob.bsky.team", "Bluesky team member"),
            ("news.nytimes.com", "News organization"),
            ("john.doe.com", "Personal domain"),
            ("support.apple.com", "Corporate account"),
            ("user.co.uk", "International domain"),
            ("verylongusername.bsky.social", "Long username"),
            ("multi.level.domain.bsky.social", "Multi-level subdomain"),
            ("celebrity.verified.com", "Verified celebrity"),
            ("dev.bsky.app", "Developer account")
        ]
        
        // Display formatting examples
        print("\n📋 FORMATTING EXAMPLES\n")
        
        for (handle, description) in demoHandles {
            print("Handle: \(handle)")
            print("Description: \(description)")
            print("Formatted outputs:")
            print("  • Smart mode:        @\(smartFormat(handle))")
            print("  • Hide common:       @\(hideCommonSuffixes(handle))")
            print("  • Hide all known:    @\(hideAllKnownSuffixes(handle))")
            print("  • Compact (max 15):  @\(formatCompact(handle, maxLength: 15))")
            print("  • Full display:      @\(handle)")
            print("-" * 60)
        }
        
        // Show use cases
        print("\n🎯 USE CASES\n")
        
        print("1. Feed/Timeline Display:")
        print("   • Shows @alice instead of @alice.bsky.social")
        print("   • Preserves @news.nytimes.com for recognition")
        print("   • Smart detection of important domains\n")
        
        print("2. Compact Views (Notifications, etc.):")
        print("   • Truncates long handles: @verylongusern…")
        print("   • Removes all known TLDs for space")
        print("   • Maintains readability\n")
        
        print("3. Profile Pages:")
        print("   • Shows more complete information")
        print("   • Respects custom domains")
        print("   • Allows full handle display option\n")
        
        print("4. Verified Accounts:")
        print("   • Always shows custom domains")
        print("   • Indicates authenticity")
        print("   • Builds trust with users\n")
        
        // Configuration options
        print("\n⚙️  CONFIGURATION OPTIONS\n")
        
        print("Users can customize:")
        print("• Display mode (Smart/Hide Common/Hide All/Full)")
        print("• Verified account handling")
        print("• Common domain filtering")
        print("• Per-context formatting")
        print("• Custom domain exceptions\n")
        
        // Benefits
        print("\n✨ BENEFITS\n")
        
        print("1. Improved Readability")
        print("   - Reduces visual clutter")
        print("   - Focuses on usernames")
        print("   - Cleaner UI\n")
        
        print("2. Smart Context Awareness")
        print("   - Shows domains when they matter")
        print("   - Hides redundant information")
        print("   - Adapts to different views\n")
        
        print("3. User Control")
        print("   - Configurable preferences")
        print("   - Live preview in settings")
        print("   - Respects user choice\n")
        
        print("4. Future-Proof Design")
        print("   - Easy to add new domains")
        print("   - Extensible architecture")
        print("   - Testable implementation\n")
    }
    
    private func smartFormat(_ handle: String) -> String {
        // Check if it's a custom domain (not in our common lists)
        let domain = handle.split(separator: ".").dropFirst().joined(separator: ".")
        let fullDomain = ".\(domain)"
        
        if !commonSuffixes.contains(fullDomain) && !wellKnownTLDs.contains(where: { fullDomain.hasSuffix($0) }) {
            return handle // Keep custom domains
        }
        
        // Remove common suffixes
        return hideCommonSuffixes(handle)
    }
    
    private func hideCommonSuffixes(_ handle: String) -> String {
        for suffix in commonSuffixes {
            if handle.hasSuffix(suffix) {
                return String(handle.dropLast(suffix.count))
            }
        }
        return handle
    }
    
    private func hideAllKnownSuffixes(_ handle: String) -> String {
        // First try common suffixes
        let afterCommon = hideCommonSuffixes(handle)
        if afterCommon != handle {
            return afterCommon
        }
        
        // Then try well-known TLDs
        for tld in wellKnownTLDs {
            if handle.hasSuffix(tld) {
                return String(handle.dropLast(tld.count))
            }
        }
        
        return handle
    }
    
    private func formatCompact(_ handle: String, maxLength: Int) -> String {
        let formatted = hideAllKnownSuffixes(handle)
        if formatted.count > maxLength {
            return String(formatted.prefix(maxLength - 1)) + "…"
        }
        return formatted
    }
}

// String multiplication helper
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// Run the demo
HandleFormatter.shared.formatDemo() 