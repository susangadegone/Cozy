import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            if showSplash {
                SplashView()
            } else if authManager.isLoading {
                loadingIndicator
            } else if !authManager.isAuthenticated {
                WelcomeView()
            } else if appState.needsOnboarding {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .onAppear { startSplash() }
    }

    private var loadingIndicator: some View {
        ProgressView()
            .tint(CozyTheme.primary)
    }

    private func startSplash() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showSplash = false
            }
            if authManager.isAuthenticated {
                Task { await appState.loadData() }
            }
        }
    }
}
