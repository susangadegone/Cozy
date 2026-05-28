import SwiftUI

// MARK: - How Cozy Works (one-time post-onboarding screen)
struct HowCozyWorksView: View {
    @EnvironmentObject var appState: AppState
    let onDismiss: () -> Void

    private var firstName: String {
        appState.profile?.displayName ?? "you"
    }

    private var tips: [CozyTip] {
        [
            CozyTip(
                number: "1",
                title: "Your chores are ready",
                body: "We seeded a starter list from the rooms you picked. Check them off, push them to a different day, or swap them out anytime."
            ),
            CozyTip(
                number: "2",
                title: "The week lives in Calendar",
                body: "See what's coming up and drag chores to days that work for you. Nothing here is locked."
            ),
            CozyTip(
                number: "3",
                title: "Add more from the library",
                body: "Tap Browse chore library on the Chores tab to grow your list when you're ready."
            )
        ]
    }

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerBlock
                            .padding(.top, 48)
                        stepsBlock
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                ctaButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome in, \(firstName).")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text("Three quick things before you dive in.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stepsBlock: some View {
        VStack(spacing: 12) {
            ForEach(tips) { tip in
                CozyTipCard(tip: tip)
            }
        }
    }

    private var ctaButton: some View {
        Button(action: onDismiss) {
            Text("Open my chores")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(CozyTheme.accent)
                .cornerRadius(CozyTheme.pillRadius)
        }
        .buttonStyle(.plain)
    }
}

private struct CozyTip: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let body: String
}

private struct CozyTipCard: View {
    let tip: CozyTip

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            numberBadge
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                Text(tip.body)
                    .font(.system(size: 14))
                    .foregroundColor(CozyTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(CozyTheme.card)
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius)
                .stroke(CozyTheme.border, lineWidth: 1)
        )
    }

    private var numberBadge: some View {
        Text(tip.number)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(CozyTheme.accent)
            .frame(width: 28, height: 28)
            .background(CozyTheme.accent.opacity(0.14))
            .clipShape(Circle())
    }
}
