import SwiftUI

struct CleanlinessGoalView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: CleanlinessType? = nil
    @State private var appeared = false

    var body: some View {
        OnboardingShell(step: 4, total: 6, onBack: { appRouter.navigate(to: .cleanlinessType) }) {
            header
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .padding(.bottom, 20)
            cards
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)
            Spacer()
            OnboardingNextButton(isEnabled: selection != nil) {
                if let s = selection {
                    onboardingVM.goalType = s
                    appRouter.navigate(to: .onboardingQ4)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            // Default to one step above current if possible
            if let current = onboardingVM.currentType,
               let idx = CleanlinessType.allCases.firstIndex(of: current),
               idx + 1 < CleanlinessType.allCases.count {
                selection = CleanlinessType.allCases[idx + 1]
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Where do you want to be?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text("Your goal shapes the pace of your plan.")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var cards: some View {
        VStack(spacing: 10) {
            ForEach(CleanlinessType.allCases, id: \.self) { type in
                GoalTypeCard(
                    type: type,
                    isCurrent: type == onboardingVM.currentType,
                    isSelected: selection == type
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = type
                    }
                }
            }
        }
    }
}

private struct GoalTypeCard: View {
    let type: CleanlinessType
    let isCurrent: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(type.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(CozyTheme.primary)
                        if isCurrent {
                            Text("you now")
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(CozyTheme.mutedText.opacity(0.15))
                                .foregroundColor(CozyTheme.mutedText)
                                .clipShape(Capsule())
                        }
                    }
                    Text(type.description)
                        .font(.system(size: 13))
                        .foregroundColor(CozyTheme.mutedText)
                        .lineLimit(2)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CozyTheme.accent)
                        .font(.system(size: 20))
                }
            }
            .padding(14)
            .background(CozyTheme.card)
            .cornerRadius(CozyTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                    .stroke(isSelected ? CozyTheme.accent : CozyTheme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
