import SwiftUI

@main
struct CozyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appRouter = AppRouter()
    @StateObject private var onboardingVM = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(appState)
                .environmentObject(appRouter)
                .environmentObject(onboardingVM)
        }
    }
}

/// Reactively routes between onboarding and main app based on profile state.
struct AppEntryView: View {
    @EnvironmentObject var appState: AppState

    private var onboardingCompleted: Bool {
        appState.profile?.onboardingCompleted ?? false
    }

    var body: some View {
        Group {
            if onboardingCompleted {
                RootView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: onboardingCompleted)
    }
}
