import SwiftUI

struct EnhancedLoginView: View {
    // MARK: - Dependencies
    let authService: BlueSkyAuthService
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    // MARK: - State Properties
    @State private var identifier = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var animationTrigger = false
    
    // MARK: - Focus State
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username
        case password
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !identifier.isEmpty && !password.isEmpty
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    loginFormSection
                    errorMessageSection
                    loginButtonSection
                    footerSection
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color.voxBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
        }
        .environment(\.editMode, .constant(.inactive))
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            iconView
            
            Text("Sign in to Bluesky")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.voxText)
            
            Text("Connect your Bluesky account to discover and share audio content")
                .font(.subheadline)
                .foregroundStyle(LinearGradient.voxSubtleGradient)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var iconView: some View {
        ZStack {
            // Gradient glow background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.voxSkyBlue.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 20)
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50, weight: .medium, design: .rounded))
                .foregroundStyle(LinearGradient.voxCoolGradient)
                .symbolEffect(.pulse, value: animationTrigger)
        }
        .padding(.top, 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animationTrigger.toggle()
            }
        }
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 16) {
            usernameField
            passwordField
            autofillHint
        }
        .padding(.horizontal)
    }
    
    private var usernameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Handle or Email")
                .font(.caption)
                .foregroundStyle(Color.voxText.opacity(0.7))
            
            TextField("username.bsky.social", text: $identifier)
                .textFieldStyle(.plain)
                .font(.system(size: 16, design: .rounded))
                .padding()
                .background(fieldBackground(isFocused: focusedField == .username))
                .textContentType(.username)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .disabled(isLoading)
                .submitLabel(.next)
                .focused($focusedField, equals: .username)
                .onSubmit {
                    focusedField = .password
                }
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.caption)
                .foregroundStyle(Color.voxText.opacity(0.7))
            
            SecureField("Bluesky password", text: $password)
                .textFieldStyle(.plain)
                .font(.system(size: 16, design: .rounded))
                .padding()
                .background(fieldBackground(isFocused: focusedField == .password))
                .textContentType(.password)
                .disabled(isLoading)
                .submitLabel(.go)
                .focused($focusedField, equals: .password)
                .onSubmit {
                    if isFormValid {
                        Task {
                            await login()
                        }
                    }
                }
        }
    }
    
    private var autofillHint: some View {
        Text("Tip: iOS can autofill your saved Bluesky password")
            .font(.caption2)
            .foregroundStyle(LinearGradient.voxSubtleGradient)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var errorMessageSection: some View {
        if let error {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(LinearGradient.voxWarmGradient)
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(Color.voxCoralRed)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.voxCoralRed.opacity(0.1))
            )
            .padding(.horizontal)
        }
    }
    
    private var loginButtonSection: some View {
        Button {
            Task {
                await login()
            }
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                Text("Sign In")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(loginButtonBackground)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(
            color: isFormValid ? Color.voxSkyBlue.opacity(0.3) : Color.clear,
            radius: 8,
            x: 0,
            y: 4
        )
        .padding(.horizontal)
        .disabled(isLoading || !isFormValid)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFormValid)
    }
    
    private var loginButtonBackground: some View {
        Group {
            if isFormValid {
                LinearGradient.voxCoolGradient
            } else {
                Color.voxText.opacity(0.2)
            }
        }
    }
    
    private var footerSection: some View {
        Text("Your credentials are encrypted and never stored")
            .font(.caption2)
            .foregroundStyle(LinearGradient.voxSubtleGradient.opacity(0.8))
            .padding(.top, 8)
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .foregroundStyle(LinearGradient.voxCoolGradient)
        .disabled(isLoading)
    }
    
    // MARK: - Helper Methods
    
    private func fieldBackground(isFocused: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? 
                        AnyShapeStyle(LinearGradient.voxCoolGradient.opacity(0.5)) : 
                        AnyShapeStyle(Color.voxText.opacity(0.1)),
                        lineWidth: 1
                    )
            )
    }
    
    // MARK: - Actions
    
    private func login() async {
        isLoading = true
        error = nil
        
        let normalizedIdentifier = normalizeIdentifier(identifier)
        
        do {
            let session = try await authService.login(
                identifier: normalizedIdentifier,
                password: password
            )
            
            await updateAppState(with: session)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private func normalizeIdentifier(_ identifier: String) -> String {
        var normalized = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove @ if present at the start
        if normalized.hasPrefix("@") {
            normalized = String(normalized.dropFirst())
        }
        
        // Add .bsky.social if no domain is specified
        if !normalized.contains("@") && !normalized.contains(".") {
            normalized = "\(normalized).bsky.social"
        }
        
        return normalized
    }
    
    private func updateAppState(with session: BlueSkyAuthService.BlueSkySession) async {
        await MainActor.run {
            appState.isAuthenticated = true
            appState.currentUser = Profile(
                id: session.did,
                handle: session.handle,
                displayName: session.handle
            )
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    EnhancedLoginView(authService: BlueSkyAuthService())
        .environmentObject(AppState())
} 
