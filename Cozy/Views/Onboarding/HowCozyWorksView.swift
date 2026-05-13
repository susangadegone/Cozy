import SwiftUI

// MARK: - How Cozy Works (one-time post-onboarding screen)
struct HowCozyWorksView: View {
    let onDismiss: () -> Void

    private let steps: [CozyTip] = [
        CozyTip(
            number: "1",
            title: "Your chores are already set up",
            body: "We added a starter set of chores based on your rooms. You can check them off, reschedule them, or swap them out anytime."
        ),
        CozyTip(
            number: "2",
            title: "Use the calendar to schedule",
            body: "Head to the calendar to see what's coming up and move chores to days that work for you."
        ),
        CozyTip(
            number: "3",
            title: "Want more chores? Browse the library",
            body: "Tap \"Browse Chore Library\" from the Chores tab to add more preset chores or create your own."
        )
    ]

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                headerBlock
                    .padding(.top, 56)
                    .padding(.horizontal, 28)
                stepsBlock
                    .padding(.top, 36)
                    .padding(.horizontal, 24)
                Spacer()
                letsGoButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Header
    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Here's how Cozy works")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text("Three things to know before you dive in.")
                .font(.system(size: 15))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Steps
    private var stepsBlock: some View {
        VStack(spacing: 14) {
            ForEach(steps) { tip in
                CozyTipCard(tip: tip)
            }
        }
    }

    // MARK: - CTA
    private var letsGoButton: some View {
        Button(action: onDismiss) {
            Text("Let's go")
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

// MARK: - Tip Model
private struct CozyTip: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let body: String
}

// MARK: - Tip Card
private struct CozyTipCard: View {
    let tip: CozyTip

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            numberBadge
            textBlock
        }
        .padding(18)
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
            .background(CozyTheme.accent.opacity(0.12))
            .clipShape(Circle())
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(tip.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text(tip.body)
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
    }
}
