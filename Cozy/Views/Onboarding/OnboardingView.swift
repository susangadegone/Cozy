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
            // Always start fresh at the name-entry step
            if appRouter.route == .splash || appRouter.route == .welcome {
                appRouter.navigate(to: .onboardingName)
            }
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch appRouter.route {
        case .onboardingName:
            OnboardingNameView()
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
        OnboardingShell(step: 0, total: 6, onBack: nil) {
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
            Text("🏡")
                .font(.system(size: 48))
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
