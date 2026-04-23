import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState

    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Cozy")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(CozyTheme.primary)
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(CozyTheme.accent)
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) { opacity = 1 }
                Task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    await route()
                }
            }
        }
    }

    @MainActor
    private func route() async {
        await authManager.checkSession()
        if authManager.isAuthenticated {
            await appState.loadData()
            appRouter.navigate(to: appState.needsOnboarding ? .onboardingQ1 : .dashboard)
        } else {
            appRouter.navigate(to: .welcome)
        }
    }
}
