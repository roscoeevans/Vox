//
//  VoxApp.swift
//  Vox
//
//  Created by Rocky Evans on 5/23/25.
//

import SwiftUI
import SwiftData

@main
struct VoxApp: App {
    // MARK: - Environment
    @StateObject private var appState = AppState()
    
    // MARK: - SwiftData Configuration
    let modelContainer: ModelContainer
    
    init() {
        // Register custom fonts
        FontRegistration.registerCustomFonts()
        
        do {
            modelContainer = try ModelContainer(
                for: Draft.self, Profile.self, Thread.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .tint(.voxSkyBlue)
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - App State
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: Profile?
    @Published var isLoading = false
    @Published var error: Error?
    
    // Add more app-wide state as needed
}
