import SwiftUI

struct ActionButton: View {
    let icon: String
    let count: Int
    let isActive: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isActive ? color : .secondary)
            }
            Text("\(count)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
} 