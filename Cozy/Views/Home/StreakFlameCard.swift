import SwiftUI

struct StreakFlameCard: View {
    @EnvironmentObject var appState: AppState
    @State private var pulsing = false
    @State private var ringAnimated = false

    private var streak: Int { appState.currentStreak }
    private var hasStreak: Bool { streak > 0 }

    // Milestone ladder
    private let milestones = [5, 7, 14, 30, 60, 100]

    private var nextMilestone: Int {
        milestones.first(where: { $0 > streak }) ?? (streak + 1)
    }
    private var prevMilestone: Int {
        milestones.last(where: { $0 <= streak }) ?? 0
    }
    private var milestoneProgress: Double {
        guard nextMilestone > prevMilestone else { return 1.0 }
        return Double(streak - prevMilestone) / Double(nextMilestone - prevMilestone)
    }

    private var ringColor: Color {
        switch streak {
        case 0:      return CozyTheme.border
        case 1...4:  return CozyTheme.accent
        case 5...13: return Color(hex: "E09A5A")
        case 14...29: return Color(hex: "D4761A")
        default:     return Color(hex: "C0392B")
        }
    }

    private var cardTint: Color {
        switch streak {
        case 0:      return Color.clear
        case 1...4:  return CozyTheme.accent.opacity(0.05)
        case 5...13: return Color(hex: "E09A5A").opacity(0.06)
        case 14...29: return Color(hex: "D4761A").opacity(0.06)
        default:     return Color(hex: "C0392B").opacity(0.05)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            flameIcon
            textBlock
            Spacer()
            milestoneRing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                CozyTheme.card
                cardTint
            }
        )
        .cornerRadius(CozyTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CozyTheme.cardCornerRadius)
                .stroke(hasStreak ? ringColor.opacity(0.3) : CozyTheme.border, lineWidth: 1)
        )
        .shadow(color: hasStreak ? ringColor.opacity(0.12) : CozyTheme.primary.opacity(0.04),
                radius: 8, x: 0, y: 3)
        .onAppear {
            if hasStreak {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulsing = true }
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) { ringAnimated = true }
        }
        .onChange(of: streak) { _, newVal in
            ringAnimated = false
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.05)) { ringAnimated = true }
            if newVal > 0 {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulsing = true }
            } else {
                pulsing = false
            }
        }
    }

    // MARK: - Flame

    private var flameIcon: some View {
        Image(systemName: hasStreak ? "flame.fill" : "moon.zzz.fill")
            .font(.system(size: 26, weight: .semibold))
            .foregroundColor(hasStreak ? ringColor : CozyTheme.mutedText)
            .scaleEffect(hasStreak && pulsing ? 1.12 : 1.0)
            .animation(
                hasStreak ? .easeInOut(duration: 1.1).repeatForever(autoreverses: true) : .default,
                value: pulsing
            )
    }

    // MARK: - Text

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

    // MARK: - Milestone ring

    private var milestoneRing: some View {
        ZStack {
            // Track
            Circle()
                .stroke(ringColor.opacity(0.15), lineWidth: 4)
                .frame(width: 52, height: 52)

            // Progress arc
            Circle()
                .trim(from: 0, to: ringAnimated ? min(milestoneProgress, 1.0) : 0)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 52, height: 52)

            // Center label
            VStack(spacing: 0) {
                Text("\(streak)")
                    .font(.system(size: hasStreak ? 16 : 14, weight: .bold, design: .rounded))
                    .foregroundColor(hasStreak ? ringColor : CozyTheme.mutedText)
                Text(hasStreak ? "days" : "–")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(ringColor.opacity(0.7))
            }

            // Milestone pip at 12 o'clock when complete
            if milestoneProgress >= 1.0 {
                Circle()
                    .fill(ringColor)
                    .frame(width: 7, height: 7)
                    .offset(y: -26)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Strings

    private var streakTitle: String {
        switch streak {
        case 1:        return "Day 1 — you started!"
        case 2...4:    return "\(streak) days going strong"
        case 5...6:    return "Almost a full week!"
        case 7:        return "One full week 🎉"
        case 8...13:   return "\(streak) days and counting"
        case 14:       return "Two weeks straight!"
        case 15...29:  return "\(streak) days — impressive"
        case 30:       return "30 days — legend 🏆"
        default:       return "\(streak)-day streak"
        }
    }

    private var streakSubtitle: String {
        let remaining = nextMilestone - streak
        if remaining == 0 { return "Milestone hit! Next: \(milestones.first(where: { $0 > streak }) ?? streak + 1) days." }
        return remaining == 1 ? "1 more day to hit \(nextMilestone)." : "\(remaining) days to \(nextMilestone)."
    }
}
