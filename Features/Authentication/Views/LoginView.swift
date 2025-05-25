import SwiftUI

struct LoginView: View {
    let authService: BlueSkyAuthService
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var identifier = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo and Welcome Text
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Welcome to Vox")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Sign in to your BlueSky account")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // Login Form
                VStack(spacing: 16) {
                    TextField("Handle or Email", text: $identifier)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.username)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                }
                .padding(.horizontal)
                
                // Error Message
                if let error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                // Login Button
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
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .disabled(isLoading)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func login() async {
        isLoading = true
        error = nil
        
        do {
            let session = try await authService.login(
                identifier: identifier,
                password: password
            )
            
            // Update app state
            await MainActor.run {
                appState.isAuthenticated = true
                appState.currentUser = Profile(
                    id: session.did,
                    handle: session.handle,
                    displayName: session.handle
                )
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView(authService: BlueSkyAuthService())
        .environmentObject(AppState())
} 