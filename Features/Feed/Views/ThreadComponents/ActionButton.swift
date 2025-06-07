import SwiftUI
import UIKit

struct ActionButton: View {
    let icon: String
    let count: Int
    let isActive: Bool
    let color: Color
    let isProcessing: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0
    
    // Get gradient based on button type - always visible
    private var buttonGradient: LinearGradient {
        switch icon {
        case let str where str.contains("heart"):
            // Warm gradient for likes
            return LinearGradient(
                colors: [.voxCoralRed, .voxCoral],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case let str where str.contains("arrow.2.squarepath"):
            // Cool gradient for reposts
            return LinearGradient(
                colors: [.voxSkyBlue, .voxPeriwinkle],
                startPoint: .top,
                endPoint: .bottom
            )
        case let str where str.contains("bubble"):
            // Periwinkle to golden gradient for replies
            return LinearGradient(
                colors: [.voxPeriwinkle, .voxGoldenYellow],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        default:
            return .voxCoolGradient
        }
    }
    
    var body: some View {
        VStack(spacing: 1) {
            Button(action: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                // Quick pulse animation
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    pulseScale = 1.15
                }
                
                // Reset scale
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8).delay(0.1)) {
                    pulseScale = 1.0
                }
                
                // Perform action
                action()
            }) {
                ZStack {
                    // Subtle active state glow
                    if isActive {
                        Circle()
                            .fill(buttonGradient.opacity(0.2))
                            .frame(width: 28, height: 28)
                            .blur(radius: 6)
                    }
                    
                    // Icon with gradient - always visible
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(buttonGradient)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                        .scaleEffect(isPressed ? 0.9 : pulseScale)
                        .animation(.spring(response: 0.15, dampingFraction: 0.8), value: isPressed)
                }
                .frame(width: 28, height: 28)
            }
            .disabled(isProcessing)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            .buttonStyle(PlainButtonStyle())
            
            // Count with gradient when active
            if count > 0 {
                Text("\(count)")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(isActive ? buttonGradient : LinearGradient(colors: [.secondary], startPoint: .top, endPoint: .bottom))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: count)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isActive)
            }
        }
        .frame(height: 38)
    }
} 