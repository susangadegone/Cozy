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

/// Decides whether to show onboarding or the main app.
/// Uses a computed property so SwiftUI re-renders reactively whenever profile changes.
struct AppEntryView: View {
    @EnvironmentObject var appState: AppState

    private var onboardingCompleted: Bool {
        appState.profile?.onboardingCompleted ?? false
    }

    var body: some View {
        Group {
            if onboardingCompleted {
                RootView()
                    .environmentObject(appState)
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .environmentObject(appState)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: onboardingCompleted)
    }
}
