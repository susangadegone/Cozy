import SwiftUI

struct ScienceTrustView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var appeared = false

    private let cards: [(title: String, detail: String, icon: String)] = [
        ("Habit stacking",     "We attach new chores to things you already do.",           "link"),
        ("Progress momentum",  "Small wins build streaks that make the next task easier.", "chart.line.uptrend.xyaxis"),
        ("Friction reduction", "Fewer taps means more follow-through.",                    "hand.tap")
    ]

    var body: some View {
        ZStack {
            CozyTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                backButton
                headerSection
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                scienceCards
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                credibilityLine
                    .padding(.top, 20)
                Spacer()
                continueButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 44)
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var backButton: some View {
        Button { appRouter.navigateBack() } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(CozyTheme.accent)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🧠")
                .font(.system(size: 36))
            Text("Built on behavioral\nscience, not guesswork.")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(2)
        }
    }

    private var scienceCards: some View {
        VStack(spacing: 12) {
            ForEach(cards, id: \.title) { card in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(CozyTheme.accent.opacity(0.12))
                            .frame(width: 42, height: 42)
                        Image(systemName: card.icon)
                            .font(.system(size: 18))
                            .foregroundColor(CozyTheme.accent)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(card.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(CozyTheme.primary)
                        Text(card.detail)
                            .font(.system(size: 14))
                            .foregroundColor(CozyTheme.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(16)
                .background(CozyTheme.card)
                .cornerRadius(CozyTheme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: CozyTheme.cornerRadius)
                        .stroke(CozyTheme.border, lineWidth: 1)
                )
            }
        }
    }

    private var credibilityLine: some View {
        Text("Designed by someone who spent 5 years in behavioral health.")
            .font(.system(size: 12))
            .foregroundColor(CozyTheme.mutedText)
    }

    private var continueButton: some View {
        Button {
            UserDefaults.standard.set(true, forKey: "hasSeenScienceScreen")
            appRouter.navigate(to: .onboardingQ1)
        } label: {
            RoundedRectangle(cornerRadius: CozyTheme.pillRadius)
                .fill(CozyTheme.accent)
                .frame(height: 54)
                .overlay(
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                )
        }
    }
}
