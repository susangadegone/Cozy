import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dragManager: DragDropManager
    var energy: TodayEnergy = .normal
    var onChoreComplete: () -> Void

    @State private var selectedChore: Chore? = nil

    private var dayChoreCap: Int { energy.cap }

    private var capped: [Chore] {
        let all = appState.todayChores
        let undone = all.filter { !$0.isDone }
        let done = all.filter { $0.isDone }
        return Array((undone + done).prefix(dayChoreCap))
    }

    private var allDone: Bool {
        !capped.isEmpty && capped.allSatisfy { $0.isDone }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            QuoteCard()
                .padding(.bottom, 12)
            StreakFlameCard()
                .environmentObject(appState)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
            sectionTitle
            progressBar
            if allDone {
                celebrationCard
                    .padding(.bottom, 4)
            }
            if capped.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 120)
        .sheet(item: $selectedChore) { chore in
            NavigationStack {
                ChoreDetailView(chore: chore).environmentObject(appState)
            }
            .presentationDetents([.fraction(0.7)])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var progressBar: some View {
        let total = capped.count
        let done = capped.filter { $0.isDone }.count
        if total > 0 {
            let ratio = Double(done) / Double(total)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CozyTheme.border.opacity(0.5))
                        .frame(height: 6)
                    Capsule()
                        .fill(ratio >= 1.0 ? CozyTheme.teal : CozyTheme.accent)
                        .frame(width: max(0, geo.size.width * ratio), height: 6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: ratio)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
    }

    private var celebrationCard: some View {
        let streak = appState.currentStreak
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("All done today")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(CozyTheme.primary)
                Text(streak > 1 ? "\(streak)-day streak" : "Keep it going tomorrow.")
                    .font(.system(size: 14, weight: streak > 1 ? .medium : .regular))
                    .foregroundColor(streak > 1 ? CozyTheme.teal : CozyTheme.mutedText)
            }
            Spacer()
            if streak > 1 {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundColor(CozyTheme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(CozyTheme.teal.opacity(0.12))
        .cornerRadius(CozyTheme.cornerRadius)
        .padding(.horizontal, 20)
    }

    private var sectionTitle: some View {
        HStack {
            Text("Today")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Spacer()
            Text("\(capped.filter { !$0.isDone }.count) left")
                .font(.system(size: 12))
                .foregroundColor(CozyTheme.mutedText)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var list: some View {
        VStack(spacing: 8) {
            ForEach(capped) { chore in
                DashChoreRow(chore: chore, onToggle: handleToggle)
                    .onTapGesture { selectedChore = chore }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Text("Nothing due today")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(CozyTheme.primary)
            Text("A quiet morning. Enjoy it.")
                .font(.system(size: 14))
                .foregroundColor(CozyTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func handleToggle(_ chore: Chore) {
        let wasUndone = !chore.isDone
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            appState.toggleChore(chore)
        }
        if wasUndone { onChoreComplete() }
    }
}

private struct DashChoreRow: View {
    @EnvironmentObject var appState: AppState
    let chore: Chore
    let onToggle: (Chore) -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Room accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(chore.isDone ? CozyTheme.border : roomAccentColor)
                .frame(width: 4)
                .padding(.vertical, 10)
                .padding(.leading, 12)
                .animation(.easeInOut(duration: 0.3), value: chore.isDone)

            HStack(spacing: 12) {
                Button { onToggle(chore) } label: {
                    ZStack {
                        Circle()
                            .strokeBorder(chore.isDone ? CozyTheme.teal : CozyTheme.border, lineWidth: 1.5)
                            .background(Circle().fill(chore.isDone ? CozyTheme.teal : Color.clear))
                            .frame(width: 24, height: 24)
                        if chore.isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: 3) {
                    Text(chore.choreName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(chore.isDone ? CozyTheme.mutedText : CozyTheme.primary)
                        .strikethrough(chore.isDone, color: CozyTheme.mutedText)
                        .lineLimit(2)
                    Text(roomName)
                        .font(.system(size: 12))
                        .foregroundColor(CozyTheme.mutedText)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(CozyTheme.card)
        .cornerRadius(14)
        .padding(.horizontal, 20)
    }

    private var roomName: String {
        Room.defaults.first(where: { $0.id == chore.roomId })?.name ?? chore.roomId.capitalized
    }

    private var roomAccentColor: Color {
        switch chore.roomId {
        case "kitchen":  return Color(hex: "E8A44A")
        case "bedroom":  return Color(hex: "B5A8D9")
        case "bathroom": return Color(hex: "6BA8C4")
        case "living":   return Color(hex: "D4956A")
        case "outdoor":  return Color(hex: "6F9B7B")
        case "laundry":  return Color(hex: "8EC5D4")
        default:         return CozyTheme.border
        }
    }
}
