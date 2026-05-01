import SwiftUI

struct OnboardingQ3View: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: String? = nil
    @State private var appeared = false

    private struct RhythmOption: Identifiable {
        let id: String
        let icon: String
    }

    private let options: [RhythmOption] = [
        RhythmOption(id: "A little every day",                icon: "sun.min"),
        RhythmOption(id: "Power session on weekends",          icon: "bolt.fill"),
        RhythmOption(id: "Mix of both",                       icon: "shuffle"),
        RhythmOption(id: "Whenever something really needs it", icon: "clock.badge.exclamationmark")
    ]

    var body: some View {
        OnboardingShell(step: 3, total: 5, onBack: { appRouter.navigate(to: .onboardingQ2) }) {
            questionHeader
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            optionsList
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            Spacer()
            OnboardingNextButton(isEnabled: selection != nil) {
                if let s = selection {
                    onboardingVM.cleaningRhythm = s
                    appRouter.navigate(to: .onboardingQ4)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("How do you prefer\nto handle chores?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
        }
    }

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(options) { opt in
                OnboardingChoiceCard(
                    label: opt.id,
                    icon: opt.icon,
                    isSelected: selection == opt.id
                ) { selection = opt.id }
            }
        }
    }
}
