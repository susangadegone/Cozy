import SwiftUI
import Supabase

@main
struct CozyApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(appState)
        }
    }
}
