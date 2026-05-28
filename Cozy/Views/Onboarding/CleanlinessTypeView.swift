import SwiftUI

struct CleanlinessTypeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var onboardingVM: OnboardingViewModel

    @State private var selection: CleanlinessType? = nil
    @State private var appeared = false

    var body: some View {
        OnboardingShell(step: 3, total: 6, onBack: { appRouter.navigate(to: .onboardingQ3) }) {
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
                    onboardingVM.currentType = s
                    appRouter.navigate(to: .cleanlinessGoal)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Where are you now?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
            Text("No judgment — this helps us start you off right.")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var cards: some View {
        VStack(spacing: 10) {
            ForEach(CleanlinessType.allCases, id: \.self) { type in
                CleanlinessTypeCard(type: type, isSelected: selection == type) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = type
                    }
                }
            }
        }
    }
}

struct CleanlinessTypeCard: View {
    let type: CleanlinessType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(CozyTheme.primary)
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
