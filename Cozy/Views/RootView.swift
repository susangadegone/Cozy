import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            if showSplash {
                SplashView()
            } else if authManager.isLoading {
                ProgressView().tint(CozyTheme.primary)
            } else if !authManager.isAuthenticated {
                WelcomeView()
            } else if appState.needsOnboarding {
                OnboardingView()
            } else {
                mainTabs
            }
        }
        .onAppear { startSplash() }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 1 ? "person.fill" : "person")
                }
                .tag(1)
        }
        .tint(CozyTheme.accent)
    }

    private func startSplash() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
            if authManager.isAuthenticated {
                Task { await appState.loadData() }
            }
        }
    }
}
