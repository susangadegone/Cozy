import SwiftUI

/// Top-level onboarding container — routes between steps via AppRouter.
struct OnboardingView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            currentScreen
        }
        .animation(.easeInOut(duration: 0.3), value: appRouter.route)
        .onAppear {
            // If we landed here from a pre-auth route, drop to name entry
            let onboardingRoutes: [AppRoute] = [
                .science, .onboardingName,
                .onboardingQ1, .onboardingQ3,
                .cleanlinessType, .cleanlinessGoal,
                .onboardingQ4, .onboardingQ5, .scheduleReady,
                .howCozyWorks, .recap
            ]
            if !onboardingRoutes.contains(appRouter.route) {
                appRouter.navigate(to: .onboardingName)
            }
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch appRouter.route {
        case .science:
            ScienceTrustView()
        case .onboardingName:
            OnboardingNameView()
        case .onboardingQ1:
            OnboardingQ1View()
        case .onboardingQ3:
            OnboardingQ3View()
        case .cleanlinessType:
            CleanlinessTypeView()
        case .cleanlinessGoal:
            CleanlinessGoalView()
        case .onboardingQ4:
            OnboardingQ4View()
        case .onboardingQ5:
            OnboardingQ5View()
        case .scheduleReady:
            ScheduleReadyView()
        case .howCozyWorks:
            HowCozyWorksView {
                if var p = appState.profile {
                    p.onboardingCompleted = true
                    appState.profile = p
                    LocalStore.shared.saveProfile(p)
                }
            }
        default:
            OnboardingNameView()
        }
    }
}

// MARK: - Name Entry Step (Step 0)

struct OnboardingNameView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var name: String = ""
    @State private var appeared = false

    var body: some View {
        OnboardingShell(step: 0, total: 6, onBack: nil) { // intro
            VStack(alignment: .leading, spacing: 0) {
                headerBlock
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .padding(.bottom, 32)
                nameField
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                Spacer()
                OnboardingNextButton(isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                    let trimmed = name.trimmingCharacters(in: .whitespaces)
                    onboardingVM.userName = trimmed.isEmpty ? "You" : trimmed
                    appRouter.navigate(to: .onboardingQ1)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome to Cozy")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text("Let's get your home set up.\nWhat should we call you?")
                .font(.system(size: 16))
                .foregroundColor(CozyTheme.mutedText)
                .lineSpacing(4)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your name")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CozyTheme.mutedText)
            TextField("e.g. Jamie", text: $name)
                .font(.system(size: 17))
                .foregroundColor(CozyTheme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(CozyTheme.card)
                .cornerRadius(CozyTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                        .stroke(name.isEmpty ? CozyTheme.border : CozyTheme.accent, lineWidth: 1.5)
                )
                .autocorrectionDisabled()
        }
    }
}
