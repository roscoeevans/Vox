import Foundation

extension String {
    /// Formats a Bluesky handle by removing the .bsky.social suffix if present
    /// - Returns: The formatted handle without the .bsky.social suffix
    func formatBlueskyHandle() -> String {
        if hasSuffix(".bsky.social") {
            return String(dropLast(".bsky.social".count))
        }
        return self
    }
} 