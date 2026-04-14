import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            routedView
        }
        .animation(.easeInOut(duration: 0.35), value: appRouter.route)
        .onChange(of: authManager.isAuthenticated) { isAuth in
            if !isAuth && appRouter.route == .dashboard {
                appRouter.navigate(to: .welcome)
            }
        }
    }

    @ViewBuilder
    private var routedView: some View {
        switch appRouter.route {
        case .splash:
            SplashView()
        case .welcome:
            WelcomeView()
        case .signUp:
            SignUpView()
        case .login:
            LoginView()
        case .science:
            ScienceTrustView()
        case .onboardingQ1:
            OnboardingQ1View()
        case .onboardingQ2:
            OnboardingQ2View()
        case .onboardingQ3:
            OnboardingQ3View()
        case .onboardingQ4:
            OnboardingQ4View()
        case .onboardingQ5:
            OnboardingQ5View()
        case .scheduleReady:
            ScheduleReadyView()
        case .dashboard:
            mainTabs
        }
    }

    private var mainTabs: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(CozyTheme.accent)
        .task { await appState.loadData() }
    }
}
