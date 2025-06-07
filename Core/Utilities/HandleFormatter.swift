import Foundation

/// A utility class for formatting Bluesky handles with configurable options
final class HandleFormatter {
    
    // MARK: - Singleton
    static let shared = HandleFormatter()
    
    // MARK: - Configuration
    struct Configuration {
        /// Domain suffixes that should always be hidden
        var alwaysHiddenSuffixes: Set<String> = [
            ".bsky.social",
            ".bsky.team",
            ".bsky.app",
            ".bsky.network"
        ]
        
        /// Domain suffixes that can be optionally hidden based on context
        var optionallyHiddenSuffixes: Set<String> = [
            ".com",
            ".org",
            ".net",
            ".io",
            ".dev",
            ".app",
            ".social",
            ".xyz",
            ".me",
            ".co",
            ".us",
            ".uk",
            ".ca",
            ".au",
            ".de",
            ".fr",
            ".jp",
            ".cn",
            ".in",
            ".br"
        ]
        
        /// Custom domains that should never be hidden (e.g., celebrity/brand domains)
        var neverHiddenDomains: Set<String> = []
        
        /// Whether to show domain for verified/notable accounts
        var showDomainForVerifiedAccounts: Bool = true
        
        /// Default display mode
        var defaultDisplayMode: DisplayMode = .smart
    }
    
    // MARK: - Display Modes
    enum DisplayMode {
        /// Always show full handle
        case full
        
        /// Hide common suffixes only
        case hideCommonSuffixes
        
        /// Hide all known suffixes
        case hideAllKnownSuffixes
        
        /// Smart mode - decides based on context
        case smart
        
        /// Custom filter function
        case custom((String) -> String)
    }
    
    // MARK: - Properties
    private(set) var configuration = Configuration()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Configuration Methods
    func updateConfiguration(_ update: (inout Configuration) -> Void) {
        update(&configuration)
    }
    
    // MARK: - Formatting Methods
    
    /// Formats a handle according to the specified display mode
    /// - Parameters:
    ///   - handle: The handle to format
    ///   - mode: The display mode to use (defaults to configuration default)
    ///   - isVerified: Whether the account is verified (affects smart mode)
    ///   - maxLength: Maximum length for the formatted handle
    /// - Returns: The formatted handle
    func format(
        _ handle: String,
        mode: DisplayMode? = nil,
        isVerified: Bool = false,
        maxLength: Int? = nil
    ) -> String {
        let effectiveMode = mode ?? configuration.defaultDisplayMode
        
        // Check if this is a never-hidden domain
        if let domain = handle.handleDomain,
           configuration.neverHiddenDomains.contains(domain) {
            return truncateIfNeeded(handle, maxLength: maxLength)
        }
        
        // Apply formatting based on mode
        let formatted: String
        switch effectiveMode {
        case .full:
            formatted = handle
            
        case .hideCommonSuffixes:
            formatted = removeCommonSuffixes(from: handle)
            
        case .hideAllKnownSuffixes:
            formatted = removeAllKnownSuffixes(from: handle)
            
        case .smart:
            formatted = smartFormat(handle, isVerified: isVerified)
            
        case .custom(let formatter):
            formatted = formatter(handle)
        }
        
        return truncateIfNeeded(formatted, maxLength: maxLength)
    }
    
    /// Batch formats multiple handles with the same settings
    func formatBatch(
        _ handles: [String],
        mode: DisplayMode? = nil,
        maxLength: Int? = nil
    ) -> [String] {
        return handles.map { format($0, mode: mode, maxLength: maxLength) }
    }
    
    // MARK: - Private Methods
    
    private func removeCommonSuffixes(from handle: String) -> String {
        for suffix in configuration.alwaysHiddenSuffixes {
            if handle.hasSuffix(suffix) {
                return String(handle.dropLast(suffix.count))
            }
        }
        return handle
    }
    
    private func removeAllKnownSuffixes(from handle: String) -> String {
        // First try common suffixes
        let afterCommon = removeCommonSuffixes(from: handle)
        if afterCommon != handle {
            return afterCommon
        }
        
        // Then try optional suffixes
        for suffix in configuration.optionallyHiddenSuffixes {
            if handle.hasSuffix(suffix) {
                return String(handle.dropLast(suffix.count))
            }
        }
        
        return handle
    }
    
    private func smartFormat(_ handle: String, isVerified: Bool) -> String {
        // Always remove known suffixes (both Bluesky and common TLDs)
        // This ensures .com, .co, etc. are always hidden
        let formatted = removeAllKnownSuffixes(from: handle)
        
        // If we removed a suffix, return the formatted version
        if formatted != handle {
            return formatted
        }
        
        // If no suffix was removed, this is a truly custom domain
        // (like @nytimes.com or @senate.gov) - show it in full
        return handle
    }
    
    private func truncateIfNeeded(_ text: String, maxLength: Int?) -> String {
        guard let maxLength = maxLength, text.count > maxLength else {
            return text
        }
        
        let truncateLength = maxLength - 1
        return String(text.prefix(truncateLength)) + "…"
    }
}

// MARK: - Convenience Extensions
extension HandleFormatter {
    /// Quick format with common settings
    func formatCompact(_ handle: String) -> String {
        return format(handle, mode: .hideAllKnownSuffixes, maxLength: 20)
    }
    
    /// Format for display in feed/timeline
    func formatForFeed(_ handle: String, isVerified: Bool = false) -> String {
        return format(handle, mode: .smart, isVerified: isVerified)
    }
    
    /// Format for profile display
    func formatForProfile(_ handle: String) -> String {
        return format(handle, mode: .hideCommonSuffixes)
    }
} 