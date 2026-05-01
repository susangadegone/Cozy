import SwiftUI

@main
struct CozyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(appState)
        }
    }
}

/// Decides whether to show onboarding or the main app
struct AppEntryView: View {
    @EnvironmentObject var appState: AppState
    @State private var showOnboarding: Bool = false

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView()
                    .environmentObject(appState)
                    .transition(.opacity)
            } else {
                RootView()
                    .environmentObject(appState)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showOnboarding)
        .onAppear {
            let completed = appState.profile?.onboardingCompleted ?? false
            showOnboarding = !completed
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            withAnimation { showOnboarding = false }
        }
    }
}
