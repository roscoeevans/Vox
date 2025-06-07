import SwiftUI

// MARK: - Selective Rounded Corners
/// A shape that allows rounding specific corners of a rectangle
/// Used for Twitter-style image layouts where only outer corners are rounded
public struct SelectiveRoundedCorners: Shape {
    public var corners: UIRectCorner
    public var radius: CGFloat
    
    public init(corners: UIRectCorner, radius: CGFloat = 12.0) {
        self.corners = corners
        self.radius = radius
    }
    
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Convenience Extensions
extension View {
    /// Clips the view to a shape with selective rounded corners
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(SelectiveRoundedCorners(corners: corners, radius: radius))
    }
} 