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
    @State private var showHowItWorks = false

    private static let howItWorksKey = "cozy.howItWorksDismissed"

    private var onboardingCompleted: Bool {
        appState.profile?.onboardingCompleted ?? false
    }

    var body: some View {
        Group {
            if onboardingCompleted {
                RootView()
                    .transition(.opacity)
                    .fullScreenCover(isPresented: $showHowItWorks) {
                        HowCozyWorksView {
                            UserDefaults.standard.set(true, forKey: Self.howItWorksKey)
                            showHowItWorks = false
                        }
                    }
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: onboardingCompleted)
        .onChange(of: onboardingCompleted) { _, completed in
            if completed {
                let dismissed = UserDefaults.standard.bool(forKey: Self.howItWorksKey)
                if !dismissed {
                    // Brief delay lets the home screen settle before presenting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showHowItWorks = true
                    }
                }
            }
        }
    }
}
