import Foundation

extension String {
    /// Common domain suffixes used in Bluesky handles that can be filtered out for display
    private static let commonHandleSuffixes = [
        ".bsky.social",
        ".bsky.team",
        ".bsky.app",
        ".bsky.network"
    ]
    
    /// Additional well-known domain suffixes that might be filtered based on context
    private static let wellKnownDomains = [
        ".com",
        ".org",
        ".net",
        ".io",
        ".dev",
        ".app",
        ".social",
        ".xyz",
        ".me",
        ".co"
    ]
    
    /// Formats a Bluesky handle by removing common suffixes if present
    /// - Parameter filterWellKnownDomains: If true, also filters out well-known TLDs (default: false)
    /// - Returns: The formatted handle without the suffix
    func formatBlueskyHandle(filterWellKnownDomains: Bool = false) -> String {
        // First check for common Bluesky-specific suffixes
        for suffix in Self.commonHandleSuffixes {
            if hasSuffix(suffix) {
                return String(dropLast(suffix.count))
            }
        }
        
        // Optionally filter well-known domains
        if filterWellKnownDomains {
            // Find the last dot to identify potential domain
            if let lastDotIndex = lastIndex(of: ".") {
                let potentialTLD = String(self[lastDotIndex...])
                if Self.wellKnownDomains.contains(potentialTLD) {
                    return String(self[..<lastDotIndex])
                }
            }
        }
        
        return self
    }
    
    /// Intelligently formats a handle based on context and length
    /// - Parameters:
    ///   - maxLength: Maximum length for the formatted handle (optional)
    ///   - alwaysShowDomain: If true, always shows the full handle including domain
    /// - Returns: A formatted handle suitable for display
    func formatHandleForDisplay(maxLength: Int? = nil, alwaysShowDomain: Bool = false) -> String {
        guard !alwaysShowDomain else { return self }
        
        // Start with basic formatting (remove common Bluesky suffixes)
        var formatted = formatBlueskyHandle()
        
        // If we have a max length constraint and the handle is still too long
        if let maxLength = maxLength, formatted.count > maxLength {
            // Try removing well-known domains if not already done
            formatted = formatBlueskyHandle(filterWellKnownDomains: true)
            
            // If still too long, truncate with ellipsis
            if formatted.count > maxLength {
                let truncateLength = maxLength - 1 // Leave room for ellipsis
                formatted = String(formatted.prefix(truncateLength)) + "…"
            }
        }
        
        return formatted
    }
    
    /// Checks if the string is a valid handle format
    var isValidHandle: Bool {
        // Basic validation - contains at least one dot and has content before and after
        let components = split(separator: ".")
        return components.count >= 2 && components.allSatisfy { !$0.isEmpty }
    }
    
    /// Extracts the domain portion of a handle
    var handleDomain: String? {
        guard isValidHandle else { return nil }
        
        if let firstDotIndex = firstIndex(of: ".") {
            return String(self[firstDotIndex...])
        }
        return nil
    }
    
    /// Extracts the username portion of a handle (before the first dot)
    var handleUsername: String? {
        guard isValidHandle else { return nil }
        
        if let firstDotIndex = firstIndex(of: ".") {
            return String(self[..<firstDotIndex])
        }
        return nil
    }
}

// MARK: - Handle Display Configuration
extension String {
    /// Configuration for how handles should be displayed in different contexts
    struct HandleDisplayConfig {
        /// Whether to filter well-known domains
        let filterWellKnownDomains: Bool
        
        /// Maximum length before truncation
        let maxLength: Int?
        
        /// Whether to always show the full domain
        let alwaysShowDomain: Bool
        
        /// Predefined configurations for common use cases
        static let compact = HandleDisplayConfig(
            filterWellKnownDomains: true,
            maxLength: 20,
            alwaysShowDomain: false
        )
        
        static let standard = HandleDisplayConfig(
            filterWellKnownDomains: false,
            maxLength: nil,
            alwaysShowDomain: false
        )
        
        static let full = HandleDisplayConfig(
            filterWellKnownDomains: false,
            maxLength: nil,
            alwaysShowDomain: true
        )
    }
    
    /// Formats a handle using a specific display configuration
    func formatHandle(using config: HandleDisplayConfig) -> String {
        return formatHandleForDisplay(
            maxLength: config.maxLength,
            alwaysShowDomain: config.alwaysShowDomain
        )
    }
} 