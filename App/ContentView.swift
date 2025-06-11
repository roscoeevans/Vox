//
//  ContentView.swift
//  Vox
//
//  Created by Rocky Evans on 5/23/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var authService = BlueSkyAuthService()
    @State private var feedService: BlueSkyFeedService
    @State private var isRestoringSession = true
    @State private var showingComposer = false
    
    init() {
        let sharedAuthService = BlueSkyAuthService()
        _authService = State(initialValue: sharedAuthService)
        _feedService = State(initialValue: BlueSkyFeedService(authService: sharedAuthService))
    }
    
    var body: some View {
        Group {
            if isRestoringSession {
                ProgressView("Restoring session...")
            } else if appState.isAuthenticated {
                ZStack(alignment: .bottomTrailing) {
                    TabView {
                        FeedView(feedService: feedService)
                            .tabItem {
                                Image(systemName: "house")
                            }
                        
                        Text("Search")
                            .tabItem {
                                Image(systemName: "magnifyingglass")
                            }
                        
                        Text("Notifications")
                            .tabItem {
                                Image(systemName: "bell")
                            }
                        
                        Text("Profile")
                            .tabItem {
                                Image(systemName: "person")
                            }
                    }
                    
                    // Floating compose button
                    Button(action: {
                        showingComposer = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(LinearGradient.voxCoolGradient)
                            .clipShape(Circle())
                            .shadow(color: Color.voxSkyBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
                .sheet(isPresented: $showingComposer) {
                    ComposePostView(feedService: feedService, authService: authService)
                }
            } else {
                LoginView(authService: authService)
            }
        }
        .environmentObject(appState)
        .task {
            await restoreSession()
        }
    }
    
    private func restoreSession() async {
        do {
            try await authService.restoreSession()
            if let session = await authService.currentSession {
                await MainActor.run {
                    appState.isAuthenticated = true
                    appState.currentUser = Profile(
                        id: session.did,
                        handle: session.handle,
                        displayName: session.handle
                    )
                    isRestoringSession = false
                }
            } else {
                await MainActor.run {
                    appState.isAuthenticated = false
                    appState.currentUser = nil
                    isRestoringSession = false
                }
            }
        } catch {
            print("[ContentView] Failed to restore session: \(error.localizedDescription)")
            await MainActor.run {
                appState.isAuthenticated = false
                appState.currentUser = nil
                isRestoringSession = false
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Feed")
                .tabItem {
                    Label("Feed", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(0)
            
            ThreadCreationView()
                .tabItem {
                    Label("New Thread", systemImage: "square.and.pencil")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
    }
}

// MARK: - Placeholder Views
struct ThreadCreationView: View {
    var body: some View {
        NavigationStack {
            Text("Thread Creation Coming Soon")
                .navigationTitle("New Thread")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            if let user = appState.currentUser {
                VStack(spacing: 20) {
                    AsyncImage(url: user.avatarURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    Text(user.displayName)
                        .font(.voxTitle2())
                    
                    Text(user.handle)
                        .font(.voxSubheadline())
                        .foregroundStyle(.secondary)
                    
                    if let bio = user.bio {
                        Text(bio)
                            .font(.voxBody())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .navigationTitle("Profile")
                .voxNavigationTitleFont()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Sign Out") {
                            // TODO: Implement sign out
                        }
                    }
                }
            } else {
                Text("Profile not available")
            }
        }
    }
}

#Preview {
    ContentView()
}
