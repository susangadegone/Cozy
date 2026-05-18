import SwiftUI

@main
struct CozyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appRouter = AppRouter()
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(appState)
                .environmentObject(appRouter)
                .environmentObject(onboardingVM)
                .environmentObject(authManager)
        }
    }
}

/// Reactively routes between splash → auth → onboarding → main app.
struct AppEntryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var authManager: AuthManager
    @State private var showSplash = true
    @State private var showHowItWorks = false

    private static let howItWorksKey = "cozy.howItWorksDismissed"

    private var onboardingCompleted: Bool {
        appState.profile?.onboardingCompleted ?? false
    }

    var body: some View {
        Group {
            if showSplash {
                SplashView { withAnimation { showSplash = false } }
                    .transition(.opacity)
            } else if !authManager.isAuthenticated {
                AuthFlowView()
                    .transition(.opacity)
            } else if onboardingCompleted {
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
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.4), value: onboardingCompleted)
        .onAppear {
            if !authManager.isAuthenticated &&
               (appRouter.route == .splash || appRouter.route == .welcome) {
                appRouter.navigate(to: .welcome)
            }
        }
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

/// Pre-auth flow: welcome → sign up / sign in → (optional science trust card).
struct AuthFlowView: View {
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            currentScreen
        }
        .animation(.easeInOut(duration: 0.3), value: appRouter.route)
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch appRouter.route {
        case .welcome:  WelcomeView()
        case .signUp:   SignUpView()
        case .login:    LoginView()
        case .science:  ScienceTrustView()
        default:        WelcomeView()
        }
    }
}
