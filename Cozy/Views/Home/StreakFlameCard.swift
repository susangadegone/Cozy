import SwiftUI

struct StreakFlameCard: View {
    @EnvironmentObject var appState: AppState
    @State private var pulsing = false

    private var streak: Int { appState.currentStreak }
    private var hasStreak: Bool { streak > 0 }

    var body: some View {
        HStack(spacing: 14) {
            flameIcon
            textBlock
            Spacer()
            if hasStreak { streakBadge }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                CozyTheme.card
                if hasStreak {
                    Color(hex: "E09A5A").opacity(0.06)
                }
            }
        )
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius)
                .stroke(hasStreak ? Color(hex: "E09A5A").opacity(0.3) : CozyTheme.border, lineWidth: 1)
        )
        .shadow(color: hasStreak ? Color(hex: "E09A5A").opacity(0.12) : CozyTheme.primary.opacity(0.04),
                radius: 8, x: 0, y: 3)
        .onAppear {
            guard hasStreak else { return }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
        .onChange(of: streak) { _, newVal in
            if newVal > 0 {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            } else {
                pulsing = false
            }
        }
    }

    // MARK: - Subviews

    private var flameIcon: some View {
        Text(hasStreak ? "🔥" : "💤")
            .font(.system(size: 28))
            .scaleEffect(hasStreak && pulsing ? 1.12 : 1.0)
            .animation(
                hasStreak ? .easeInOut(duration: 1.1).repeatForever(autoreverses: true) : .default,
                value: pulsing
            )
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(hasStreak ? streakTitle : "No streak yet")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text(hasStreak ? streakSubtitle : "Complete today's chores to start one.")
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
        }
    }

    private var streakBadge: some View {
        VStack(spacing: 1) {
            Text("\(streak)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "E09A5A"))
            Text("days")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "E09A5A").opacity(0.75))
        }
        .frame(width: 48, height: 48)
        .background(Color(hex: "E09A5A").opacity(0.1))
        .clipShape(Circle())
    }

    // MARK: - Computed strings

    private var streakTitle: String {
        switch streak {
        case 1:       return "Day 1 — you started!"
        case 2...4:   return "\(streak) days going strong"
        case 5...6:   return "Almost a full week!"
        case 7:       return "One full week 🎉"
        case 8...13:  return "\(streak) days and counting"
        case 14:      return "Two weeks straight!"
        case 15...29: return "\(streak) days — impressive"
        case 30:      return "30 days — legend 🏆"
        default:      return "\(streak)-day streak"
        }
    }

    private var streakSubtitle: String {
        if streak >= 7 { return "Keep the flame alive — don't break it." }
        let remaining = 7 - (streak % 7)
        return remaining == 1 ? "1 more day to hit \((streak / 7 + 1) * 7)." : "\(remaining) days to your next milestone."
    }

}