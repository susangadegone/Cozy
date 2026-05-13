import SwiftUI

struct NextBadgeCard: View {
    @EnvironmentObject var appState: AppState

    private var earnedIds: Set<String> {
        Set(appState.profile?.earnedBadgeIds ?? [])
    }

    private var nextBadge: BadgeDefinition? {
        BadgeService.all.first { !earnedIds.contains($0.id) }
    }

    private var earnedCount: Int { earnedIds.count }
    private var totalCount: Int { BadgeService.all.count }
    private var progress: Double { Double(earnedCount) / Double(totalCount) }

    var body: some View {
        PSection(title: "Progress", icon: "chart.bar.fill") {
            if earnedCount >= totalCount {
                allUnlockedState
            } else if let badge = nextBadge {
                nextBadgeRow(badge)
            }
        }
    }

    // MARK: - Next badge row

    private func nextBadgeRow(_ badge: BadgeDefinition) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(badge.icon)
                    .font(.system(size: 26))
                    .frame(width: 44, height: 44)
                    .background(CozyTheme.accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text("Next up:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(CozyTheme.mutedText)
                        Text(badge.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(CozyTheme.primary)
                    }
                    Text(badge.description)
                        .font(.system(size: 12))
                        .foregroundColor(CozyTheme.mutedText)
                        .lineLimit(2)
                }
                Spacer()
            }

            overallProgressBar
        }
    }

    // MARK: - Overall bar

    private var overallProgressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(earnedCount) of \(totalCount) badges")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(CozyTheme.mutedText)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(CozyTheme.accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CozyTheme.border)
                        .frame(height: 8)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [CozyTheme.accent, Color(hex: "E09A5A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * progress), height: 8)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - All unlocked

    private var allUnlockedState: some View {
        HStack(spacing: 12) {
            Text("🎉")
                .font(.system(size: 26))
                .frame(width: 44, height: 44)
                .background(Color(hex: "4CAF82").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text("All badges unlocked!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                Text("You've earned every badge. You're a Cozy legend.")
                    .font(.system(size: 12))
                    .foregroundColor(CozyTheme.mutedText)
            }
            Spacer()
        }
    }
}
