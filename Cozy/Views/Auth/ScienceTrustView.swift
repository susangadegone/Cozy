import SwiftUI

struct ScienceTrustView: View {
    @EnvironmentObject var appRouter: AppRouter

    private let cards: [(title: String, detail: String, icon: String)] = [
        ("Habit stacking", "We attach new chores to things you already do.", "link"),
        ("Progress momentum", "Small wins build streaks that make the next task easier.", "chart.line.uptrend.xyaxis"),
        ("Friction reduction", "Fewer taps means more follow-through.", "hand.tap")
    ]

    var body: some View {
        ZStack {
            Color(hex: "FAF7F2").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.bottom, 28)
                scienceCards
                credibilityLine
                    .padding(.top, 20)
                Spacer()
                continueButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 44)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Built on behavioral science,\nnot guesswork.")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(CozyTheme.primary)
                .lineSpacing(3)
        }
    }

    private var scienceCards: some View {
        VStack(spacing: 14) {
            ForEach(cards, id: \.title) { card in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: card.icon)
                        .font(.system(size: 22))
                        .foregroundColor(CozyTheme.accent)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(CozyTheme.primary)
                        Text(card.detail)
                            .font(.system(size: 14))
                            .foregroundColor(CozyTheme.primary.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color(hex: "F5EDE4"))
                .cornerRadius(14)
            }
        }
    }

    private var credibilityLine: some View {
        Text("Designed by someone who spent 5 years in behavioral health.")
            .font(.system(size: 12))
            .foregroundColor(CozyTheme.mutedText)
            .multilineTextAlignment(.leading)
    }

    private var continueButton: some View {
        Button {
            UserDefaults.standard.set(true, forKey: "hasSeenScienceScreen")
            appRouter.navigate(to: .onboardingQ1)
        } label: {
            Text("Continue")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(CozyTheme.primary)
                .cornerRadius(CozyTheme.cornerRadius)
        }
    }
}
