import SwiftUI

// MARK: - Feed Spacing Constants
enum FeedSpacing {
    /// Vertical padding for post content (top and bottom)
    static let postVerticalPadding: CGFloat = 12
    
    /// Horizontal padding for post content
    static let postHorizontalPadding: CGFloat = 16
    
    /// Vertical padding for the separator between posts
    static let separatorVerticalPadding: CGFloat = 2
    
    /// Height of the separator line
    static let separatorHeight: CGFloat = 1
    
    /// Padding for action buttons
    static let actionButtonPadding: CGFloat = 12
    
    /// Total vertical space between posts (calculated)
    static var totalVerticalSpacing: CGFloat {
        return postVerticalPadding + separatorVerticalPadding + separatorHeight + separatorVerticalPadding + postVerticalPadding
    }
}

// MARK: - Convenience View Extensions
extension View {
    func feedPostPadding() -> some View {
        self.padding(.horizontal, FeedSpacing.postHorizontalPadding)
            .padding(.vertical, FeedSpacing.postVerticalPadding)
    }
    
    func feedActionBarPadding() -> some View {
        self.padding(.top, FeedSpacing.actionButtonPadding)
            .padding(.bottom, FeedSpacing.actionButtonPadding)
            .padding(.trailing, 8)
    }
} 