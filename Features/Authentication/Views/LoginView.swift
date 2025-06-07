import SwiftUI

struct LoginView: View {
    let authService: BlueSkyAuthService
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var showManualLogin = false
    @State private var showBlueskyInfo = false
    @State private var animationTrigger = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient.voxFullScreenGradient
                    .ignoresSafeArea()
                
                VStack {
                    // VOX Logo with gradient effect
                    Text("VOX")
                        .font(.system(size: 100, weight: .black, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(-5)
                        .padding(.top, 80)
                        .shadow(color: Color.voxSkyBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                        .scaleEffect(animationTrigger ? 1.05 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                animationTrigger.toggle()
                            }
                        }
                    
                    Spacer()
                    
                    // Bottom buttons with enhanced styling
                    VStack(spacing: 16) {
                        // Sign in with Bluesky button
                        Button {
                            showManualLogin = true
                        } label: {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                Text("Sign in with Bluesky")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(LinearGradient.voxCoolGradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.voxSkyBlue.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Create an account button with gradient border
                        Button {
                            // Open Bluesky account creation
                            if let url = URL(string: "https://bsky.app/signup") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Create an account")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                            .foregroundStyle(LinearGradient.voxWarmGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(LinearGradient.voxWarmGradient, lineWidth: 2)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // What's Bluesky? button with subtle gradient
                        Button {
                            showBlueskyInfo = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "questionmark.circle")
                                    .font(.caption)
                                Text("What's Bluesky?")
                                    .font(.caption)
                            }
                            .foregroundStyle(LinearGradient.voxSubtleGradient)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showBlueskyInfo) {
                BlueskyInfoView()
            }
            .sheet(isPresented: $showManualLogin) {
                EnhancedLoginView(authService: authService)
                    .environmentObject(appState)
            }
        }
    }
}

// Custom button style for scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// Bluesky info sheet with enhanced design
struct BlueskyInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("What is Bluesky?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient.voxCoolGradient)
                        .padding(.top)
                    
                    Text("Bluesky is a decentralized social network that gives you control over your data and online experience.")
                        .font(.body)
                        .foregroundColor(.voxText)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(
                            icon: "person.2.fill",
                            title: "Your Network, Your Rules",
                            description: "Follow who you want, see what you want. No algorithms deciding for you.",
                            gradient: .voxWarmGradient,
                            glowColor: .voxGoldenYellow
                        )
                        
                        InfoRow(
                            icon: "lock.fill",
                            title: "Own Your Data",
                            description: "Your posts and connections belong to you. Take them anywhere.",
                            gradient: .voxCoolGradient,
                            glowColor: .voxSkyBlue
                        )
                        
                        InfoRow(
                            icon: "bubble.left.and.bubble.right.fill",
                            title: "Open Protocol",
                            description: "Built on AT Protocol, an open standard for social networking.",
                            gradient: LinearGradient(
                                colors: [.voxPeriwinkle, .voxBabyBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            glowColor: .voxPeriwinkle
                        )
                    }
                    
                    Text("How Vox Uses Bluesky")
                        .font(.headline)
                        .foregroundStyle(LinearGradient.voxSubtleGradient)
                        .padding(.top)
                    
                    Text("Vox connects to your Bluesky account to help you discover and share audio content with your network. Your login credentials are secure and never stored by Vox.")
                        .font(.body)
                        .foregroundColor(.voxText.opacity(0.8))
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .background(Color.voxBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(LinearGradient.voxCoolGradient)
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    let glowColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                // Subtle glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [glowColor.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(gradient)
                    .frame(width: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.voxText)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.voxText.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LoginView(authService: BlueSkyAuthService())
        .environmentObject(AppState())
} 
