import Foundation

extension Date {
    /// Returns a human-readable string representing how long ago this date was
    /// Examples: "just now", "5m ago", "3h ago", "2d ago", "4w ago", "1y ago"
    func timeAgoString() -> String {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.year, .weekOfYear, .day, .hour, .minute, .second],
            from: self,
            to: now
        )
        
        if let years = components.year, years > 0 {
            return "\(years)y ago"
        }
        
        if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks)w ago"
        }
        
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        }
        
        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        }
        
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        }
        
        return "just now"
    }
}

extension String {
    /// Parses an ISO8601 date string and returns a time ago string
    /// Returns the original string if parsing fails
    func timeAgoFromISO8601() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Try with fractional seconds first
        if let date = formatter.date(from: self) {
            return date.timeAgoString()
        }
        
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: self) {
            return date.timeAgoString()
        }
        
        // Return original string if parsing fails
        return self
    }
} 